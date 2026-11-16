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

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isCheckingSession = true
    /// Set once the EULA gate has confirmed acceptance for this sign-in.
    @State private var eulaAccepted = false

    private func signOut() {
        isLoggedIn = false
        eulaAccepted = false
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
                HomeView(
                    onLogout: {
                        signOut()
                    },
                    onSessionExpired: {
                        signOut()
                    }
                )
            } else {
                LoginView { userId in
                    isLoggedIn = true
                }
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
}
