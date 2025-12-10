import Foundation

class AuthManager {
    static let shared = AuthManager()

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: accessTokenKey)
        }
    }

    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: refreshTokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey)
        }
    }

    func saveTokens(from response: AuthResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
    }

    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
    }
}
