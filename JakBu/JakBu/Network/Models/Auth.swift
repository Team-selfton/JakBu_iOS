import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let name: String
}

struct LoginRequest: Codable {
    let accountId: String
    let password: String
}

struct SignupRequest: Codable {
    let accountId: String
    let password: String
    let name: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
