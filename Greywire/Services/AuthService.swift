import Foundation

/// Authentication service for Greywire.
/// Same login mechanism as Prosaurus: POST /api/auth/login, keep the JWT,
/// send it as Bearer header and jwtToken cookie on later calls.
actor AuthService {
    static let shared = AuthService()

    private init() {}

    func login(handle: String, password: String) async -> AuthResult<Int> {
        let result = await APIClient.shared.login(handle: handle, password: password)

        switch result {
        case .success(let response):
            guard let token = response.token else {
                return .error("No token received")
            }

            // Save token and provisional username
            await KeychainManager.shared.saveToken(token)
            await KeychainManager.shared.saveUsername(handle.trimmingCharacters(in: .whitespaces))

            // Fetch user info to get the real username and user ID
            let meResult = await APIClient.shared.getMe()
            switch meResult {
            case .success(let me):
                await KeychainManager.shared.saveUsername(me.username)
                return .success(me.userId)
            case .error:
                // Login worked even if /me failed; return 0 as fallback
                return .success(0)
            }

        case .error(let message, let unauthorized):
            return .error(message, unauthorized: unauthorized)
        }
    }

    func logout() async {
        // Clear locally first so the user is signed out even if the call fails
        await KeychainManager.shared.clearAll()
        await APIClient.shared.logout()
    }

    func isLoggedIn() async -> Bool {
        await KeychainManager.shared.isLoggedIn()
    }

    func getStoredUsername() async -> String? {
        await KeychainManager.shared.getUsername()
    }

    /// Check if the current session is still valid by calling /me
    func validateSession() async -> Bool {
        let result = await APIClient.shared.getMe()
        switch result {
        case .success:
            return true
        case .error(_, let unauthorized):
            if unauthorized {
                await KeychainManager.shared.clearAll()
            }
            return false
        }
    }
}
