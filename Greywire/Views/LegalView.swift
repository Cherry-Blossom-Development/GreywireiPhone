import SwiftUI

struct LegalView: View {
    @State private var isLoading = true
    @State private var eulaAccepted = false
    @State private var eulaAcceptedAt: String?

    var body: some View {
        ZStack {
            Color.greywireBg.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(Color.greywireCopper)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Documents associated with your Greywire account.")
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireMuted)
                            .padding(.bottom, 8)

                        // EULA Card
                        NavigationLink {
                            EulaView()
                        } label: {
                            LegalDocumentCard(
                                title: "End User License Agreement",
                                description: "Governs your use of the Greywire community.",
                                status: eulaAccepted ? .accepted : .pending,
                                statusDate: eulaAcceptedAt
                            )
                        }
                        .buttonStyle(.plain)

                        // Privacy Policy Card
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            LegalDocumentCard(
                                title: "Privacy Policy",
                                description: "Describes how we collect, use, and protect your data.",
                                status: .acknowledged,
                                statusDate: nil
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Legal Documents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.greywireBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await loadEulaStatus()
        }
    }

    private func loadEulaStatus() async {
        isLoading = true
        let result = await APIClient.shared.getEulaStatus()
        switch result {
        case .success(let status):
            eulaAccepted = status.accepted
            eulaAcceptedAt = status.acceptedAt
        case .error:
            // If we can't fetch status, assume accepted to not block user
            eulaAccepted = true
        }
        isLoading = false
    }
}

// MARK: - Document Status

enum LegalDocumentStatus {
    case accepted
    case acknowledged
    case pending
}

// MARK: - Document Card

private struct LegalDocumentCard: View {
    let title: String
    let description: String
    let status: LegalDocumentStatus
    let statusDate: String?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireCopper)

                Text(description)
                    .font(.greywireCaption)
                    .foregroundStyle(Color.greywireMuted)

                if status == .accepted, let dateStr = statusDate {
                    Text("Accepted on \(formatLegalDate(dateStr))")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireMuted)
                } else if status == .acknowledged {
                    Text("Acknowledged by creating an account")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireMuted)
                        .italic()
                }
            }

            Spacer()

            statusBadge
        }
        .padding(16)
        .background(Color.greywireSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.greywireLine, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .accepted, .acknowledged:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                Text(status == .accepted ? "Accepted" : "Acknowledged")
                    .font(.plexMono(11, weight: .medium))
            }
            .foregroundStyle(Color.greywireSignal)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.greywireSignal.opacity(0.15))
            .clipShape(Capsule())

        case .pending:
            Text("Pending")
                .font(.plexMono(11, weight: .medium))
                .foregroundStyle(Color.greywireCopperSoft)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.greywireCopper.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    private func formatLegalDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }

        guard let date else { return dateStr }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}
