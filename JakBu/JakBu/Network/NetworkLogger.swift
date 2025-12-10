import Foundation

class NetworkLogger {
    static let shared = NetworkLogger()

    func log(request: URLRequest) {
        print("--------------------- REQUEST ---------------------")
        defer { print("----------------------------------------------------") }

        if let url = request.url {
            print("URL: \(url)")
        }
        if let method = request.httpMethod {
            print("Method: \(method)")
        }
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    func log(response: URLResponse, data: Data) {
        print("--------------------- RESPONSE --------------------")
        defer { print("----------------------------------------------------") }

        if let response = response as? HTTPURLResponse {
            print("StatusCode: \(response.statusCode)")
        }
        if let headers = (response as? HTTPURLResponse)?.allHeaderFields {
            print("Headers: \(headers)")
        }
        if let dataString = String(data: data, encoding: .utf8) {
            print("Data: \(dataString)")
        }
    }
}
