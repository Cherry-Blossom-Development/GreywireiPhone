import SwiftUI

// MARK: - Tab Enum

/// The app's main sections, in bottom bar order. They match the web
/// community's menu (Chat, Sessions, Friends, Profile), plus Home.
enum GreywireTab: String, CaseIterable {
    case home
    case sessions
    case chat
    case friends
    case profile

    var label: String {
        switch self {
        case .home: "Home"
        case .sessions: "Sessions"
        case .chat: "Chat"
        case .friends: "Friends"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .sessions: "music.note.list"
        case .chat: "bubble.left.and.bubble.right"
        case .friends: "person.2"
        case .profile: "person"
        }
    }

    var testTag: String {
        "tab-\(rawValue)"
    }
}

// MARK: - Tab Bottom Bar

/// The bottom tab bar: surface background with a line on top (like the site's
/// header border), copper for the selected tab, mono labels.
struct GreywireTabBar: View {
    @Binding var selected: GreywireTab
    let onSelect: (GreywireTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(GreywireTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                            Text(tab.label)
                                .font(.plexMono(11, weight: .regular))
                        }
                        .foregroundStyle(tab == selected ? Color.greywireCopper : Color.greywireMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .accessibilityIdentifier(tab.testTag)
                }
            }
            .padding(.bottom, 4)
            .background(Color.greywireSurface)
        }
    }
}

// MARK: - Profile Tab Screen

struct ProfileTabView: View {
    let username: String?
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabTopBar(title: "Profile")

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)

                    Eyebrow("Signed in")
                    SectionHeading(username ?? "Your account")

                    Spacer().frame(height: 16)

                    GreywireCard {
                        Text("Your profile, settings and other members' profiles are coming soon.")
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireMuted)
                    }

                    Spacer().frame(height: 24)

                    GreywireGhostButton(title: "Sign out") {
                        onLogout()
                    }
                    .accessibilityIdentifier("logout-button")

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 632, alignment: .center)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .accessibilityIdentifier("profile-screen")
    }
}

// MARK: - Tab Top Bar (no back button)

private struct TabTopBar: View {
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.greywireTitle)
                .foregroundStyle(Color.greywireText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)
        }
    }
}
