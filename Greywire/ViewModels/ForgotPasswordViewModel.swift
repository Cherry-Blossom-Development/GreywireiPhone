import Foundation

@MainActor
@Observable
final class ForgotPasswordViewModel {
    var email: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isSent: Bool = false

    func sendResetLink() async {
        guard !isLoading else { return }

        let emailTrimmed = email.trimmingCharacters(in: .whitespaces)

        // Validate email
        if emailTrimmed.isEmpty {
            errorMessage = "Enter your email address"
            return
        }

        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
            .ignoresCase()
        if emailTrimmed.firstMatch(of: emailRegex) == nil {
            errorMessage = "Enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        let result = await APIClient.shared.forgotPassword(email: emailTrimmed)

        isLoading = false

        switch result {
        case .success:
            isSent = true
        case .error(let message, _, _):
            errorMessage = message
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
