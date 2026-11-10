import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var username: String?
    var membership: MembershipResponse?
    var isLoading: Bool = false
    var errorMessage: String?
    var sessionExpired: Bool = false

    init() {
        // Load stored username immediately
        Task {
            username = await AuthService.shared.getStoredUsername()
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        // First check /me to validate session and get username
        let meResult = await APIClient.shared.getMe()

        switch meResult {
        case .success(let me):
            username = me.username
        case .error(_, let unauthorized):
            if unauthorized {
                isLoading = false
                sessionExpired = true
                return
            }
            // Keep existing username if /me fails but not 401
        }

        // Then fetch membership
        let membershipResult = await APIClient.shared.getMembership()

        isLoading = false

        switch membershipResult {
        case .success(let data):
            membership = data
        case .error(let message, let unauthorized):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func logout() async {
        await AuthService.shared.logout()
    }
}
