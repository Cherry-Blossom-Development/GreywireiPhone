import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel = ForgotPasswordViewModel()
    @FocusState private var emailFocused: Bool

    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button
            GreywireTopBar(title: "Reset password", onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 32)

                    if viewModel.isSent {
                        // Success state
                        successView
                    } else {
                        // Form state
                        formView
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 420)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .accessibilityIdentifier("forgot-password-screen")
    }

    private var formView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Eyebrow("Greywire Studio")
            Text("Forgot your password?")
                .font(.greywireDisplay)
                .foregroundStyle(Color.greywireText)
                .accessibilityAddTraits(.isHeader)

            Spacer().frame(height: 8)

            Text("Enter your email address and we'll send you a link to reset your password.")
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)

            Spacer().frame(height: 28)

            // Email field
            GreywireTextField(
                label: "Email",
                text: $viewModel.email,
                isEnabled: !viewModel.isLoading
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .submitLabel(.done)
            .focused($emailFocused)
            .onSubmit {
                emailFocused = false
                Task { await viewModel.sendResetLink() }
            }
            .accessibilityIdentifier("email-input")

            // Error message
            if let error = viewModel.errorMessage {
                Spacer().frame(height: 16)
                Text(error)
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireError)
                    .accessibilityIdentifier("error-message")
            }

            Spacer().frame(height: 28)

            // Send button
            GreywireButton(
                title: "Send reset link",
                action: {
                    emailFocused = false
                    Task { await viewModel.sendResetLink() }
                },
                isLoading: viewModel.isLoading,
                isEnabled: !viewModel.isLoading
            )
            .accessibilityIdentifier("send-reset-button")

            // Back to login link
            Spacer().frame(height: 12)
            Button {
                onBack()
            } label: {
                Text("Back to sign in")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireCopper)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("back-to-login-button")

            Spacer().frame(height: 32)
        }
        .onChange(of: viewModel.email) { _, _ in viewModel.clearError() }
    }

    private var successView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.greywireSignal)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 24)

            Text("Check your email")
                .font(.greywireDisplay)
                .foregroundStyle(Color.greywireText)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("reset-sent-message")

            Spacer().frame(height: 12)

            Text("We sent a password reset link to:")
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 4)

            Text(viewModel.email)
                .font(.greywireBody)
                .foregroundStyle(Color.greywireText)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 12)

            Text("The link expires in 1 hour.")
                .font(.greywireCaption)
                .foregroundStyle(Color.greywireMuted)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 32)

            // Back to sign in button
            GreywireButton(
                title: "Back to sign in",
                action: onBack
            )
            .accessibilityIdentifier("back-to-login-button")

            Spacer().frame(height: 32)
        }
    }
}
