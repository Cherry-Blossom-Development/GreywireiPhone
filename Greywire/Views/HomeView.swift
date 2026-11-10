import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    let onLogout: () -> Void
    let onSessionExpired: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            GreywireHeader {
                GreywireGhostButton(title: "Sign out") {
                    Task {
                        await viewModel.logout()
                        onLogout()
                    }
                }
                .accessibilityIdentifier("logout-button")
            }

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
                    MembershipCard(viewModel: viewModel)
                        .accessibilityIdentifier("membership-card")
                    Spacer().frame(height: 40)

                    // Pedals
                    SectionDivider()
                    Eyebrow("The pedals")
                    SectionHeading("The first two Linework pedals")
                    Spacer().frame(height: 16)

                    ForEach(LineworkPedals) { pedal in
                        PedalCard(pedal: pedal)
                        Spacer().frame(height: 16)
                    }

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

// MARK: - Membership Card

private struct MembershipCard: View {
    let viewModel: HomeViewModel

    var body: some View {
        GreywireCard {
            if viewModel.isLoading && viewModel.membership == nil {
                ProgressView()
                    .tint(Color.greywireCopper)
                    .frame(maxWidth: .infinity, alignment: .center)
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
                } else {
                    StatusPill(text: "Not a member yet")
                    Spacer().frame(height: 12)
                    Text("Greywire membership comes with a Greywire pedal. Once you own one, claim it with its serial number to join.")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)
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

private struct PedalCard: View {
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
