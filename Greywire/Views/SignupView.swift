import SwiftUI

struct SignupView: View {
    @State private var viewModel = SignupViewModel()
    @FocusState private var focusedField: Field?

    let onSignupSuccess: (Int) -> Void
    let onBack: () -> Void

    enum Field: Hashable {
        case handle, firstName, lastName, email, password, confirmPassword
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button
            GreywireTopBar(title: "Create an account", onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 32)

                    // Header
                    Eyebrow("Greywire Studio")
                    Text("Join Greywire")
                        .font(.greywireDisplay)
                        .foregroundStyle(Color.greywireText)
                        .accessibilityAddTraits(.isHeader)

                    Spacer().frame(height: 8)

                    Text("One account works on Greywire and Prosaurus. If you already have a Prosaurus account, sign in with it instead.")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)

                    Spacer().frame(height: 28)

                    // Username field
                    GreywireTextField(
                        label: "Username",
                        text: $viewModel.handle,
                        isEnabled: !viewModel.isLoading
                    )
                    .textContentType(.username)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .handle)
                    .onSubmit { focusedField = .firstName }
                    .accessibilityIdentifier("signup-username-input")

                    Spacer().frame(height: 16)

                    // First name and last name side by side
                    HStack(spacing: 12) {
                        GreywireTextField(
                            label: "First name",
                            text: $viewModel.firstName,
                            isEnabled: !viewModel.isLoading,
                            capitalization: .words
                        )
                        .textContentType(.givenName)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .firstName)
                        .onSubmit { focusedField = .lastName }
                        .accessibilityIdentifier("first-name-input")

                        GreywireTextField(
                            label: "Last name",
                            text: $viewModel.lastName,
                            isEnabled: !viewModel.isLoading,
                            capitalization: .words
                        )
                        .textContentType(.familyName)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .lastName)
                        .onSubmit { focusedField = .email }
                        .accessibilityIdentifier("last-name-input")
                    }

                    Spacer().frame(height: 16)

                    // Email field
                    GreywireTextField(
                        label: "Email",
                        text: $viewModel.email,
                        isEnabled: !viewModel.isLoading
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
                    .accessibilityIdentifier("email-input")

                    Spacer().frame(height: 16)

                    // Password field
                    GreywireTextField(
                        label: "Password",
                        text: $viewModel.password,
                        isSecure: true,
                        isEnabled: !viewModel.isLoading
                    )
                    .textContentType(.newPassword)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .onSubmit { focusedField = .confirmPassword }
                    .accessibilityIdentifier("password-input")

                    Spacer().frame(height: 16)

                    // Confirm password field
                    GreywireTextField(
                        label: "Confirm password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        isEnabled: !viewModel.isLoading
                    )
                    .textContentType(.newPassword)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .confirmPassword)
                    .onSubmit {
                        focusedField = nil
                        Task { await viewModel.signup() }
                    }
                    .accessibilityIdentifier("confirm-password-input")

                    // Error message
                    if let error = viewModel.errorMessage {
                        Spacer().frame(height: 16)
                        Text(error)
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireError)
                            .accessibilityIdentifier("error-message")
                    }

                    Spacer().frame(height: 28)

                    // Create account button
                    GreywireButton(
                        title: "Create account",
                        action: {
                            focusedField = nil
                            Task { await viewModel.signup() }
                        },
                        isLoading: viewModel.isLoading,
                        isEnabled: !viewModel.isLoading
                    )
                    .accessibilityIdentifier("create-account-button")

                    // Back to login link
                    Spacer().frame(height: 12)
                    Button {
                        onBack()
                    } label: {
                        Text("Already have an account? Sign in")
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireCopper)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(viewModel.isLoading)
                    .accessibilityIdentifier("go-to-login-button")

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 420)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .onChange(of: viewModel.isSuccess) { _, success in
            if success {
                onSignupSuccess(viewModel.userId)
            }
        }
        .onChange(of: viewModel.handle) { _, _ in viewModel.clearError() }
        .onChange(of: viewModel.firstName) { _, _ in viewModel.clearError() }
        .onChange(of: viewModel.lastName) { _, _ in viewModel.clearError() }
        .onChange(of: viewModel.email) { _, _ in viewModel.clearError() }
        .onChange(of: viewModel.password) { _, _ in viewModel.clearError() }
        .onChange(of: viewModel.confirmPassword) { _, _ in viewModel.clearError() }
    }
}

// MARK: - Top Bar Component

struct GreywireTopBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.greywireText)
                }
                .accessibilityIdentifier("back-button")

                Spacer()

                Text(title)
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Spacer()

                // Invisible spacer to balance the back button
                Image(systemName: "chevron.left")
                    .font(.body.weight(.medium))
                    .opacity(0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)
        }
    }
}
