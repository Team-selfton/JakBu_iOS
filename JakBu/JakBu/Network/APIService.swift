import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(message: String)
}

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://jakbu-api.dsmhs.kr")!
    private var cancellables = Set<AnyCancellable>()

    private func request<T: Decodable>(endpoint: String, method: String, body: (any Encodable)? = nil, needsAuth: Bool = false) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if needsAuth {
            if let token = AuthManager.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: APIError.decodingFailed(error)).eraseToAnyPublisher()
            }
        }

        NetworkLogger.shared.log(request: request)

        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                NetworkLogger.shared.log(response: output.response, data: output.data)
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.decodingFailed(error)
                }
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

    func refreshToken(request: RefreshTokenRequest) -> AnyPublisher<AuthResponse, APIError> {
        return self.request(endpoint: "/auth/refresh-token", method: "POST", body: request)
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
}
