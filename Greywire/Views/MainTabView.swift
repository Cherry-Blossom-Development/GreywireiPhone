import SwiftUI

/// The main tab-based navigation container. Shows the bottom tab bar
/// and manages navigation between tabs and to full-screen overlays.
struct MainTabView: View {
    @State private var selectedTab: GreywireTab = .home
    @State private var showClaimPedal = false
    @State private var showLegal = false
    @State private var showPaywall = false
    @State private var paywallMessage = ""
    @State private var homeViewModel = HomeViewModel()

    let onLogout: () -> Void
    let onSessionExpired: () -> Void

    /// Show the paywall when a 402 response is received.
    func showSubscriptionRequired(message: String) {
        paywallMessage = message
        showPaywall = true
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    HomeTabContent(
                        viewModel: homeViewModel,
                        onClaimPedal: { showClaimPedal = true },
                        onOpenLegal: { showLegal = true },
                        onSessionExpired: onSessionExpired
                    )
                case .sessions:
                    SessionsTabView()
                case .chat:
                    ChatTabView()
                case .friends:
                    FriendsView(onSessionExpired: onSessionExpired)
                case .profile:
                    ProfileTabView(username: homeViewModel.username) {
                        Task {
                            await homeViewModel.logout()
                            onLogout()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom tab bar
            GreywireTabBar(selected: $selectedTab) { tab in
                selectedTab = tab
            }
        }
        .background(Color.greywireBg)
        .fullScreenCover(isPresented: $showClaimPedal) {
            ClaimPedalView(
                onBack: { showClaimPedal = false },
                onDone: {
                    showClaimPedal = false
                    // Refresh membership after claiming
                    Task { await homeViewModel.load() }
                },
                onSessionExpired: {
                    showClaimPedal = false
                    onSessionExpired()
                }
            )
        }
        .fullScreenCover(isPresented: $showLegal) {
            LegalNavigationView(onBack: { showLegal = false })
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(
                message: paywallMessage,
                onDismiss: { showPaywall = false }
            )
        }
    }
}

// MARK: - Home Tab Content

/// The Home tab content, which is a modified version of the original HomeView
/// that integrates with the tab navigation.
private struct HomeTabContent: View {
    let viewModel: HomeViewModel
    let onClaimPedal: () -> Void
    let onOpenLegal: () -> Void
    let onSessionExpired: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header (no sign out - that's moved to Profile)
            GreywireHeader()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero
                    Spacer().frame(height: 40)
                    Eyebrow(viewModel.username.map { "Signed in as \($0)" } ?? "Linework series")
                    Text("Your pedalboard,\nconnected.")
                        .font(.greywireDisplay)
                        .foregroundStyle(Color.greywireText)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("home-title")

                    Spacer().frame(height: 12)

                    Text("Set up sounds and setlists here, and Switchyard changes every Linework pedal on your board with one tap.")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)

                    Spacer().frame(height: 40)

                    // Membership
                    SectionDivider()
                    Eyebrow("Membership")
                    SectionHeading("Your Greywire account")
                    Spacer().frame(height: 16)
                    MembershipCardContent(
                        viewModel: viewModel,
                        onClaimPedal: onClaimPedal
                    )
                    .accessibilityIdentifier("membership-card")
                    Spacer().frame(height: 40)

                    // Pedals
                    SectionDivider()
                    Eyebrow("The pedals")
                    SectionHeading("The first two Linework pedals")
                    Spacer().frame(height: 16)

                    ForEach(LineworkPedals) { pedal in
                        PedalInfoCard(pedal: pedal)
                        Spacer().frame(height: 16)
                    }

                    Spacer().frame(height: 40)

                    // Legal
                    SectionDivider()
                    Eyebrow("Legal")
                    SectionHeading("Terms and policies")
                    Spacer().frame(height: 16)

                    Button(action: onOpenLegal) {
                        GreywireCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Legal Documents")
                                        .font(.greywireTitle)
                                        .foregroundStyle(Color.greywireText)
                                    Text("EULA, Privacy Policy")
                                        .font(.greywireCaption)
                                        .foregroundStyle(Color.greywireMuted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.greywireMuted)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("legal-card")

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
    }
}

// MARK: - Membership Card Content

private struct MembershipCardContent: View {
    let viewModel: HomeViewModel
    let onClaimPedal: () -> Void

    var body: some View {
        GreywireCard {
            if viewModel.isLoading && viewModel.membership == nil {
                ProgressView()
                    .tint(Color.greywireCopper)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.isGuest {
                // Guest accounts can never be members
                StatusPill(text: "Guest account")
                Spacer().frame(height: 12)
                Text("Guest accounts can't claim pedals or become Greywire members. Create a full account to unlock all features.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            } else if let membership = viewModel.membership {
                if membership.member {
                    StatusPill(text: "Member", dotColor: .greywireSignal)
                    Spacer().frame(height: 12)

                    if membership.pedals.isEmpty {
                        Text("Your membership was granted by Greywire Studio. Pedals you claim will show up here.")
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireMuted)
                    } else {
                        Text("Your pedals")
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireText)
                        Spacer().frame(height: 8)

                        ForEach(membership.pedals) { pedal in
                            HStack {
                                Text(pedal.model)
                                    .font(.greywireBody)
                                    .foregroundStyle(Color.greywireText)
                                Spacer()
                                Text(pedal.serial)
                                    .font(.greywireMonoSmall)
                                    .foregroundStyle(Color.greywireMuted)
                            }
                            .padding(.vertical, 6)
                        }
                    }

                    Spacer().frame(height: 16)

                    GreywireGhostButton(title: "Claim another pedal") {
                        onClaimPedal()
                    }
                    .accessibilityIdentifier("claim-pedal-button")
                } else {
                    StatusPill(text: "Not a member yet")
                    Spacer().frame(height: 12)
                    Text("Greywire membership comes with a Greywire pedal. Once you own one, claim it with its serial number to join.")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)

                    Spacer().frame(height: 16)

                    GreywireGhostButton(title: "Claim a pedal") {
                        onClaimPedal()
                    }
                    .accessibilityIdentifier("claim-pedal-button")
                }
            } else {
                Text(viewModel.errorMessage ?? "Couldn't load your membership.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }
}

// MARK: - Pedal Card

private struct PedalInfoCard: View {
    let pedal: PedalInfo

    var body: some View {
        GreywireCard {
            Text(pedal.name)
                .font(.greywireTitle)
                .foregroundStyle(Color.greywireText)
            Spacer().frame(height: 2)
            Text(pedal.type)
                .font(.greywireMonoSmall)
                .foregroundStyle(Color.greywireMuted)
            Spacer().frame(height: 10)
            Text(pedal.blurb)
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
            Spacer().frame(height: 14)
            StatusPill(text: pedal.status)
        }
    }
}

// MARK: - Legal Navigation View

/// Full-screen legal documents navigation with its own NavigationStack.
private struct LegalNavigationView: View {
    let onBack: () -> Void

    var body: some View {
        NavigationStack {
            LegalView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onBack) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.greywireText)
                        }
                    }
                }
        }
    }
}

// MARK: - Static Pedal Data

private struct PedalInfo: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let blurb: String
    let status: String
}

private let LineworkPedals = [
    PedalInfo(
        name: "Flashover",
        type: "Analog distortion / overdrive",
        blurb: "A classic op-amp distortion with a tone control, soft or hard clipping, and knobs Switchyard can set for you.",
        status: "Prototyping"
    ),
    PedalInfo(
        name: "Switchyard",
        type: "Control pedal",
        blurb: "Two footswitches, a song and part readout, and a direct connection to your phone. The brain of the board.",
        status: "Design"
    )
]
