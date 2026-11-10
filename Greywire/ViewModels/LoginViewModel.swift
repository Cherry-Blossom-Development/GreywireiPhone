import Foundation

@MainActor
@Observable
final class LoginViewModel {
    var handle: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isSuccess: Bool = false
    var userId: Int = 0

    func login() async {
        guard !isLoading else { return }

        // Validate input
        if handle.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty {
            errorMessage = "Enter your username and password"
            return
        }

        isLoading = true
        errorMessage = nil

        let result = await AuthService.shared.login(
            handle: handle.trimmingCharacters(in: .whitespaces),
            password: password
        )

        isLoading = false

        switch result {
        case .success(let id):
            userId = id
            isSuccess = true
        case .error(let message, _):
            errorMessage = message
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
