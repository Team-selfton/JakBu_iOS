import Foundation
import Combine

enum APIError: Error, Equatable, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case unauthorized // For 401 Unauthorized - often due to incorrect credentials
    case sessionExpired // For 403 Forbidden or expired tokens that cannot be refreshed
    case serverError(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .requestFailed(_): // Removed error.localizedDescription
            return "네트워크 연결을 확인해주세요."
        case .invalidResponse:
            return "서버 응답 처리 중 문제가 발생했습니다."
        case .decodingFailed(_): // Removed error.localizedDescription
            return "데이터를 읽어오는 중 오류가 발생했습니다."
        case .unauthorized:
            return "비밀번호가 틀렸습니다."
        case .sessionExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .serverError(_): // Removed message
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.sessionExpired, .sessionExpired):
            return true
        case (.serverError(let lMsg), .serverError(let rMsg)):
            return lMsg == rMsg
        case (.requestFailed, .requestFailed):
            // Cannot compare associated error directly for Equatable
            return true
        case (.decodingFailed, .decodingFailed):
            // Cannot compare associated error directly for Equatable
            return true
        default:
            return false
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://jakbu-api.dsmhs.kr")!
    private var cancellables = Set<AnyCancellable>()
    private var isRefreshing = false
    private var requestsToRetry: [() -> AnyPublisher<Any, APIError>] = []

    private func request<T: Decodable>(endpoint: String, method: String, body: (any Encodable)? = nil, needsAuth: Bool = false) -> AnyPublisher<T, APIError> {
        let urlRequest = self.createRequest(endpoint: endpoint, method: method, body: body, needsAuth: needsAuth)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .handleEvents(receiveOutput: { output in
                NetworkLogger.shared.log(response: output.response, data: output.data)
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                if httpResponse.statusCode == 403 {
                    throw APIError.sessionExpired
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingFailed(error)
            }
            .catch { error -> AnyPublisher<T, APIError> in
                if error == .unauthorized {
                    return self.refreshTokenAndRetry(request: { self.request(endpoint: endpoint, method: method, body: body, needsAuth: needsAuth) })
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func createRequest(endpoint: String, method: String, body: (any Encodable)? = nil, needsAuth: Bool = false) -> URLRequest {
        let url = URL(string: endpoint, relativeTo: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if needsAuth {
            if let token = AuthManager.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        NetworkLogger.shared.log(request: request)
        return request
    }

    private func refreshTokenAndRetry<T>(request: @escaping () -> AnyPublisher<T, APIError>) -> AnyPublisher<T, APIError> {
        guard let refreshToken = AuthManager.shared.refreshToken else {
            return Fail(error: APIError.sessionExpired).eraseToAnyPublisher()
        }

        let tokenRequest = RefreshTokenRequest(refreshToken: refreshToken)
        let requestPublisher: AnyPublisher<AuthResponse, APIError> = self.request(endpoint: "/auth/refresh-token", method: "POST", body: tokenRequest)

        return requestPublisher
            .flatMap { response -> AnyPublisher<T, APIError> in
                AuthManager.shared.saveTokens(from: response)
                return request()
            }
            .catch { error -> AnyPublisher<T, APIError> in
                AuthManager.shared.clearTokens()
                return Fail(error: APIError.sessionExpired).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Auth
    func signup(request: SignupRequest) -> AnyPublisher<AuthResponse, APIError> {
        return self.request(endpoint: "/auth/signup", method: "POST", body: request)
    }

    func login(request: LoginRequest) -> AnyPublisher<AuthResponse, APIError> {
        return self.request(endpoint: "/auth/login", method: "POST", body: request)
    }

    // MARK: - ToDo
    func createTodo(request: CreateTodoRequest) -> AnyPublisher<Todo, APIError> {
        return self.request(endpoint: "/todo", method: "POST", body: request, needsAuth: true)
    }

    func getTodayTodos() -> AnyPublisher<[Todo], APIError> {
        return self.request(endpoint: "/todo/today", method: "GET", needsAuth: true)
    }

    func getTodosByDate(date: String) -> AnyPublisher<[Todo], APIError> {
        return self.request(endpoint: "/todo/date?date=\(date)", method: "GET", needsAuth: true)
    }

    func toggleTodoStatus(id: Int) -> AnyPublisher<Todo, APIError> {
        return self.request(endpoint: "/todo/\(id)/done", method: "POST", needsAuth: true)
    }

    func setTodoStatus(id: Int, request: SetTodoStatusRequest) -> AnyPublisher<Todo, APIError> {
        return self.request(endpoint: "/todo/\(id)/status", method: "POST", body: request, needsAuth: true)
    }

    func deleteTodo(id: Int) -> AnyPublisher<Void, APIError> {
        let urlRequest = self.createRequest(endpoint: "/todo/\(id)", method: "DELETE", needsAuth: true)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .handleEvents(receiveOutput: { output in
                NetworkLogger.shared.log(response: output.response, data: output.data)
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                if httpResponse.statusCode == 403 {
                    throw APIError.sessionExpired
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.invalidResponse
                }
                return ()
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.requestFailed(error)
            }
            .catch { error -> AnyPublisher<Void, APIError> in
                if error == .unauthorized {
                    return self.refreshTokenAndRetry(request: { self.deleteTodo(id: id) })
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

