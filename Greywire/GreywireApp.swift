import SwiftUI

@main
struct GreywireApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

/// Root navigation state machine for the app.
enum AuthScreen {
    case login
    case signup
    case forgotPassword
}

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isCheckingSession = true
    /// Set once the EULA gate has confirmed acceptance for this sign-in.
    @State private var eulaAccepted = false
    /// Current auth screen when not logged in.
    @State private var authScreen: AuthScreen = .login

    private func signOut() {
        isLoggedIn = false
        eulaAccepted = false
        authScreen = .login
    }

    var body: some View {
        Group {
            if isCheckingSession {
                // Loading state while checking saved session
                ZStack {
                    Color.greywireBg.ignoresSafeArea()
                    ProgressView()
                        .tint(Color.greywireCopper)
                }
            } else if isLoggedIn && !eulaAccepted {
                // Signed-in launches go through the EULA check before Home
                EulaGateView(
                    onAccepted: {
                        eulaAccepted = true
                    },
                    onDecline: {
                        Task { await AuthService.shared.logout() }
                        signOut()
                    },
                    onSessionExpired: {
                        Task { await AuthService.shared.logout() }
                        signOut()
                    }
                )
            } else if isLoggedIn {
                // Main app with tab navigation
                MainTabView(
                    onLogout: {
                        signOut()
                    },
                    onSessionExpired: {
                        signOut()
                    }
                )
            } else {
                // Auth screens
                authScreens
            }
        }
        .task {
            // Check if user has a saved session
            let hasSession = await AuthService.shared.isLoggedIn()
            if hasSession {
                // Validate the session is still good
                let isValid = await AuthService.shared.validateSession()
                isLoggedIn = isValid
            }
            isCheckingSession = false
        }
    }

    @ViewBuilder
    private var authScreens: some View {
        switch authScreen {
        case .login:
            LoginView(
                onLoginSuccess: { userId in
                    isLoggedIn = true
                },
                onCreateAccount: {
                    authScreen = .signup
                },
                onForgotPassword: {
                    authScreen = .forgotPassword
                }
            )
        case .signup:
            SignupView(
                onSignupSuccess: { userId in
                    isLoggedIn = true
                },
                onBack: {
                    authScreen = .login
                }
            )
        case .forgotPassword:
            ForgotPasswordView(
                onBack: {
                    authScreen = .login
                }
            )
        }
    }
}
