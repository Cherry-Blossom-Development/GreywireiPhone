import Foundation
import Security

/// Secure storage for auth tokens using the iOS Keychain.
/// Uses a Greywire-specific service name to keep tokens separate from Prosaurus.
actor KeychainManager {
    static let shared = KeychainManager()

    private let serviceName = "com.cherryblossomdev.greywire"
    private let tokenKey = "authToken"
    private let usernameKey = "username"

    private init() {}

    // MARK: - Token

    func saveToken(_ token: String) {
        save(key: tokenKey, value: token)
    }

    func getToken() -> String? {
        get(key: tokenKey)
    }

    func deleteToken() {
        delete(key: tokenKey)
    }

    // MARK: - Username

    func saveUsername(_ username: String) {
        save(key: usernameKey, value: username)
    }

    func getUsername() -> String? {
        get(key: usernameKey)
    }

    func deleteUsername() {
        delete(key: usernameKey)
    }

    // MARK: - Clear All

    func clearAll() {
        deleteToken()
        deleteUsername()
    }

    // MARK: - Helpers

    func isLoggedIn() -> Bool {
        getToken() != nil
    }

    func getBearerToken() -> String? {
        guard let token = getToken() else { return nil }
        return "Bearer \(token)"
    }

    // MARK: - Private Keychain Operations

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing item first
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
