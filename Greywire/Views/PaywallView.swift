import SwiftUI

/// A view that shows when a subscription is required (402 response).
/// For now, directs users to the website to subscribe until in-app purchase is implemented.
struct PaywallView: View {
    let message: String
    let onDismiss: () -> Void

    @State private var billingPlan: BillingPlanResponse?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            GreywireTopBar(title: "Subscription Required", onBack: onDismiss)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 32)

                    // Icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.greywireCopper)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer().frame(height: 24)

                    Text("Feature Limit Reached")
                        .font(.greywireHeadline)
                        .foregroundStyle(Color.greywireText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer().frame(height: 12)

                    Text(message)
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Spacer().frame(height: 32)

                    // Current plan status
                    if isLoading {
                        ProgressView()
                            .tint(Color.greywireCopper)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        planStatusCard
                    }

                    Spacer().frame(height: 32)

                    // Subscription benefits
                    GreywireCard {
                        Text("Greywire Studio Pro")
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireText)

                        Spacer().frame(height: 12)

                        benefitRow("Unlimited session recordings")
                        benefitRow("Unlimited band memberships")
                        benefitRow("Priority support")
                        benefitRow("Works on Greywire and Prosaurus")
                    }

                    Spacer().frame(height: 24)

                    // For now, direct to website
                    Text("In-app purchase coming soon. For now, subscribe at greywirestudio.com to unlock all features.")
                        .font(.greywireCaption)
                        .foregroundStyle(Color.greywireMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Spacer().frame(height: 24)

                    GreywireButton(title: "Got it") {
                        onDismiss()
                    }

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 520)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .task {
            await loadBillingPlan()
        }
    }

    private var planStatusCard: some View {
        GreywireCard {
            Text("Your Plan")
                .font(.greywireTitle)
                .foregroundStyle(Color.greywireText)

            Spacer().frame(height: 12)

            if let plan = billingPlan {
                HStack {
                    Text("Status")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)
                    Spacer()
                    StatusPill(
                        text: plan.subscribed ? "Pro" : "Free",
                        dotColor: plan.subscribed ? .greywireSignal : .greywireCopper
                    )
                }

                if plan.subscribed, let expiresAt = plan.expiresAt {
                    Spacer().frame(height: 8)
                    HStack {
                        Text("Renews")
                            .font(.greywireBody)
                            .foregroundStyle(Color.greywireMuted)
                        Spacer()
                        Text(formatDate(expiresAt))
                            .font(.greywireMonoSmall)
                            .foregroundStyle(Color.greywireText)
                    }
                }

                // Show Greywire membership if available
                if let membership = plan.greywire, membership.member {
                    Spacer().frame(height: 12)
                    Text("You're a Greywire member with \(membership.pedals.count) pedal(s), which gives you unlimited access on Greywire.")
                        .font(.greywireCaption)
                        .foregroundStyle(Color.greywireSignal)
                }
            } else {
                Text("Free tier")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }

    private func benefitRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.greywireSignal)
                .font(.caption)
            Text(text)
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
        }
        .padding(.vertical, 4)
    }

    private func loadBillingPlan() async {
        isLoading = true
        let result = await APIClient.shared.getBillingPlan()
        isLoading = false

        switch result {
        case .success(let plan):
            billingPlan = plan
        case .error:
            // Not fatal - just show without plan details
            break
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }

        guard let date else { return dateStr }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}
