import SwiftUI

struct ClaimPedalView: View {
    @State private var viewModel = ClaimPedalViewModel()
    @FocusState private var serialFocused: Bool

    let onBack: () -> Void
    let onDone: () -> Void
    let onSessionExpired: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GreywireTopBar(title: "Claim a pedal", onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 32)

                    if let claimed = viewModel.claimedPedal {
                        ClaimedView(
                            pedal: claimed,
                            alreadyYours: viewModel.alreadyYours,
                            onDone: onDone
                        )
                    } else {
                        ClaimFormView(
                            viewModel: viewModel,
                            serialFocused: $serialFocused,
                            onClaim: {
                                serialFocused = false
                                Task { await viewModel.claim() }
                            }
                        )
                    }

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 520)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .accessibilityIdentifier("claim-screen")
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
        .onChange(of: viewModel.serial) { _, _ in
            viewModel.clearError()
        }
    }
}

// MARK: - Claim Form

private struct ClaimFormView: View {
    let viewModel: ClaimPedalViewModel
    var serialFocused: FocusState<Bool>.Binding
    let onClaim: () -> Void

    private var isMember: Bool { viewModel.membership?.member == true }
    private var heldPedals: [GreywirePedal] { viewModel.membership?.pedals ?? [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow("Membership")
            Text(isMember ? "Claim another pedal" : "Claim your pedal")
                .font(.greywireHeadline)
                .foregroundStyle(Color.greywireText)
                .accessibilityAddTraits(.isHeader)

            Spacer().frame(height: 12)

            Text("Every Greywire pedal comes with a free membership, with no subscription, for as long as you own it. Enter the pedal's serial number to add it to your account.")
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)

            // Show existing pedals if member
            if !heldPedals.isEmpty {
                Spacer().frame(height: 20)
                GreywireCard {
                    Text("Your pedals")
                        .font(.greywireTitle)
                        .foregroundStyle(Color.greywireText)
                    Spacer().frame(height: 8)
                    ForEach(heldPedals) { pedal in
                        PedalRow(pedal: pedal)
                    }
                }
            }

            Spacer().frame(height: 24)

            // Serial number input
            GreywireTextField(
                label: "Pedal serial number",
                text: Binding(
                    get: { viewModel.serial },
                    set: { viewModel.serial = $0 }
                ),
                isEnabled: !viewModel.isClaiming,
                capitalization: .characters,
                placeholder: "e.g. E4629C1B23456789",
                isMonospaced: true
            )
            .submitLabel(.done)
            .focused(serialFocused)
            .onSubmit { onClaim() }
            .accessibilityIdentifier("serial-input")

            Spacer().frame(height: 6)

            Text("16 characters: the digits 0 to 9 and the letters A to F. Spaces and dashes are fine.")
                .font(.greywireCaption)
                .foregroundStyle(Color.greywireMuted)

            // Error message
            if let error = viewModel.errorMessage {
                Spacer().frame(height: 16)
                Text(error)
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireError)
                    .accessibilityIdentifier("claim-error")
            }

            Spacer().frame(height: 24)

            // Claim button
            GreywireButton(
                title: "Claim my pedal",
                action: onClaim,
                isLoading: viewModel.isClaiming,
                isEnabled: !viewModel.isClaiming && !viewModel.serial.trimmingCharacters(in: .whitespaces).isEmpty
            )
            .accessibilityIdentifier("claim-button")

            Spacer().frame(height: 24)

            Text("Bought a pedal second-hand and it's already claimed? Contact support and we'll move it to your account.")
                .font(.greywireCaption)
                .foregroundStyle(Color.greywireMuted)
        }
    }
}

// MARK: - Claimed View

private struct ClaimedView: View {
    let pedal: GreywirePedal
    let alreadyYours: Bool
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow("Membership")
            Text(alreadyYours ? "Already yours" : "You're in!")
                .font(.greywireHeadline)
                .foregroundStyle(Color.greywireText)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("claim-success")

            Spacer().frame(height: 12)

            Text(alreadyYours
                 ? "This pedal is already registered to your account."
                 : "Your \(pedal.model) is now registered to you, and membership is free for as long as you own it.")
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)

            Spacer().frame(height: 20)

            GreywireCard {
                StatusPill(text: "Member", dotColor: .greywireSignal)
                Spacer().frame(height: 12)
                PedalRow(pedal: pedal)
            }

            Spacer().frame(height: 24)

            GreywireButton(
                title: "Done",
                action: onDone
            )
            .accessibilityIdentifier("claim-done-button")
        }
    }
}

// MARK: - Pedal Row

private struct PedalRow: View {
    let pedal: GreywirePedal

    var body: some View {
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
