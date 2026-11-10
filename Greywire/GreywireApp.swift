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

    var body: some View {
        Group {
            if isCheckingSession {
                // Loading state while checking saved session
                ZStack {
                    Color.greywireBg.ignoresSafeArea()
                    ProgressView()
                        .tint(Color.greywireCopper)
                }
            } else if isLoggedIn {
                HomeView(
                    onLogout: {
                        isLoggedIn = false
                    },
                    onSessionExpired: {
                        isLoggedIn = false
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
