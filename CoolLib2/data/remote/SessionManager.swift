import Foundation

@Observable
final class SessionManager {
    static let shared = SessionManager()
    
    private let tokenKey = "auth_token"
    private let usernameKey = "auth_username"
    
    var isLoggedIn: Bool = false

    init() {
        self.isLoggedIn = getToken() != nil
    }

    func getToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func getUsername() -> String? {
        UserDefaults.standard.string(forKey: usernameKey)
    }

    func saveSession(token: String, username: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
        isLoggedIn = true
    }

    func clearSession() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        isLoggedIn = false
    }
}
