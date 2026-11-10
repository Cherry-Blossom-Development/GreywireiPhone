import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var passwordVisible = false
    @FocusState private var focusedField: Field?

    let onLoginSuccess: (Int) -> Void

    enum Field {
        case handle, password
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Brand
                GreywireBrand(logoSize: 44, textSize: 22)

                Spacer().frame(height: 40)

                // Header
                Eyebrow("Linework series")
                Text("Sign in")
                    .font(.greywireDisplay)
                    .foregroundStyle(Color.greywireText)
                    .accessibilityAddTraits(.isHeader)

                Spacer().frame(height: 8)

                Text("Use your Greywire account. It's the same account you use on Prosaurus.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)

                Spacer().frame(height: 32)

                // Username field
                GreywireTextField(
                    label: "Username or email",
                    text: $viewModel.handle,
                    isEnabled: !viewModel.isLoading
                )
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .focused($focusedField, equals: .handle)
                .onSubmit { focusedField = .password }
                .accessibilityIdentifier("username-input")

                Spacer().frame(height: 16)

                // Password field
                GreywireTextField(
                    label: "Password",
                    text: $viewModel.password,
                    isSecure: true,
                    isEnabled: !viewModel.isLoading
                )
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit {
                    focusedField = nil
                    Task { await viewModel.login() }
                }
                .accessibilityIdentifier("password-input")

                // Error message
                if let error = viewModel.errorMessage {
                    Spacer().frame(height: 16)
                    Text(error)
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireError)
                        .accessibilityIdentifier("error-message")
                }

                Spacer().frame(height: 28)

                // Sign in button
                GreywireButton(
                    title: "Sign in",
                    action: {
                        focusedField = nil
                        Task { await viewModel.login() }
                    },
                    isLoading: viewModel.isLoading,
                    isEnabled: !viewModel.isLoading
                )
                .accessibilityIdentifier("login-button")

                // Version number
                Spacer().frame(height: 48)
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")")
                    .font(.greywireMonoSmall)
                    .foregroundStyle(Color.greywireMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: 420)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .onChange(of: viewModel.isSuccess) { _, success in
            if success {
                onLoginSuccess(viewModel.userId)
            }
        }
        .onChange(of: viewModel.handle) { _, _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.password) { _, _ in
            viewModel.clearError()
        }
    }
}
