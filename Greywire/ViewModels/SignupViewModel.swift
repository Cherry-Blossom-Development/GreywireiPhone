import Foundation

@MainActor
@Observable
final class SignupViewModel {
    var handle: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isSuccess: Bool = false
    var userId: Int = 0

    func signup() async {
        guard !isLoading else { return }

        // Validate input
        let problem = validate()
        if let problem {
            errorMessage = problem
            return
        }

        isLoading = true
        errorMessage = nil

        let result = await APIClient.shared.signup(
            handle: handle.trimmingCharacters(in: .whitespaces),
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            password: password
        )

        switch result {
        case .success(let response):
            if let token = response.token {
                await KeychainManager.shared.saveToken(token)
                await KeychainManager.shared.saveUsername(handle.trimmingCharacters(in: .whitespaces))

                // Fetch user ID
                let meResult = await APIClient.shared.getMe()
                if case .success(let me) = meResult {
                    await KeychainManager.shared.saveUsername(me.username)
                    userId = me.userId
                }
                isLoading = false
                isSuccess = true
            } else {
                isLoading = false
                errorMessage = "Account created, but no token was received. Try signing in."
            }
        case .error(let message, _):
            isLoading = false
            errorMessage = message
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func validate() -> String? {
        let fields = [handle, firstName, lastName, email, password]
        if fields.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            return "Fill in all the fields"
        }

        let emailTrimmed = email.trimmingCharacters(in: .whitespaces)
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
            .ignoresCase()
        if emailTrimmed.firstMatch(of: emailRegex) == nil {
            return "Enter a valid email address"
        }

        if password.count < 6 {
            return "Use a password of at least 6 characters"
        }

        if password != confirmPassword {
            return "The passwords don't match"
        }

        return nil
    }
}
