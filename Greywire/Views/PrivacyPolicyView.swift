import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Privacy Policy")
                        .font(.greywireDisplay)
                        .foregroundStyle(Color.greywireText)
                        .multilineTextAlignment(.center)

                    Text("Greywire Studio community")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)

                    Text("Effective Date: October 22, 2026")
                        .font(.greywireCaption)
                        .foregroundStyle(Color.greywireMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                // Intro
                Text("This Privacy Policy describes how Cherry Blossom Development LLC (\"we,\" \"us,\" or \"our\"), based in Spokane, Washington, collects, uses, and protects your information when you use the Greywire Studio community at community.greywirestudio.com (the \"Community\"). By using the Community, you agree to the practices described in this policy.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
                    .padding(16)
                    .background(Color.greywireSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.greywireCopper.opacity(0.5), lineWidth: 1)
                    )

                // Section 1
                PrivacySectionView(number: "1", title: "Age Requirement") {
                    Text("The Community is intended for use by adults only. You must be at least ")
                    + Text("18 years of age").fontWeight(.semibold)
                    + Text(" to create an account or use this Community. We do not knowingly collect personal information from anyone under the age of 18. If we become aware that a user under 18 has provided us with personal information, we will promptly delete that account and its associated data. If you believe a minor has registered, please contact us at the address listed below.")
                }

                // Section 2
                PrivacySectionView(
                    number: "2",
                    title: "Information We Collect",
                    body: "We collect information you provide directly, as well as certain information automatically:\n\nInformation You Provide\n\n• Account Information: Username, email address, and password when you register.\n\n• Profile Information: Display name, profile photo, bio, and any other details you choose to add to your profile.\n\n• User Content: Chat messages, recordings, band pages, setlists, comments, ratings, and other content you create or share within the Community.\n\n• Pedal Information: The serial number and model of any Greywire pedal you claim, and when you claimed it.\n\n• Payment Information: Greywire membership is free, and we collect no payment details for it. If you use paid Prosaurus features with the same account, billing details are processed by our payment provider. We do not store full payment card numbers on our servers.\n\n• Communications: Any information you send us via email or support requests.\n\nInformation Collected Automatically\n\n• Browser Information: Browser type, operating system, and device type.\n\n• Usage Data: Features accessed, content viewed, and interactions within the Community.\n\n• Log Data: IP address, access times, and error reports to help us diagnose and fix technical issues.\n\n• Authentication Tokens: Session tokens stored securely to keep you logged in."
                )

                // Section 3
                PrivacySectionView(
                    number: "3",
                    title: "How We Use Your Information",
                    body: "We use the information we collect to:\n\n• Provide, operate, and improve the Community and its features.\n\n• Authenticate your identity and maintain the security of your account.\n\n• Check pedal serial claims and manage memberships.\n\n• Send you service-related notifications (e.g., account verification, password resets, friend activity).\n\n• Respond to your support requests and communications.\n\n• Monitor and enforce our Terms of Service, including age restrictions.\n\n• Detect and prevent fraud, abuse, or other harmful activity.\n\n• Analyze usage trends to improve the user experience.\n\nWe do not sell your personal information to third parties. We do not use your data for behavioral advertising or share it with advertisers."
                )

                // Section 4
                PrivacySectionView(
                    number: "4",
                    title: "How We Share Your Information",
                    body: "We may share your information only in the following limited circumstances:\n\n• With Other Users: Your username and profile are visible to other members. Recordings you share with a public link can be heard by anyone who has the link.\n\n• With Prosaurus: Your account is shared with Prosaurus (prosaurus.com), another service run by Cherry Blossom Development LLC. Your profile, friends, and direct messages are the same on both sites. Chat rooms, recordings, and bands stay on the site where they were created.\n\n• Service Providers: We work with trusted third-party vendors who assist us in operating the Community (e.g., payment processing, cloud hosting, email delivery). These providers are contractually obligated to protect your information and may not use it for their own purposes.\n\n• Legal Requirements: We may disclose your information if required to do so by law, court order, or governmental authority, or when we believe disclosure is necessary to protect the rights or safety of our users or the public.\n\n• Business Transfers: In the event of a merger, acquisition, or sale of company assets, your information may be transferred as part of that transaction. We will notify you of any such change."
                )

                // Section 5
                PrivacySectionView(
                    number: "5",
                    title: "Data Retention",
                    body: "We retain your personal information for as long as your account is active or as needed to provide you with services. If you delete your account, we will delete or anonymize your personal data within a reasonable period, except where we are required to retain it for legal or legitimate business purposes (such as resolving disputes or complying with legal obligations).\n\nContent you have shared that other users have interacted with (such as comments on a post) may remain in a modified form after account deletion to preserve the integrity of those interactions."
                )

                // Section 6
                PrivacySectionView(
                    number: "6",
                    title: "Data Security",
                    body: "We take reasonable technical and organizational measures to protect your information from unauthorized access, loss, or misuse. These measures include encrypted connections (HTTPS/TLS), secure password hashing, and access controls on our servers. However, no method of transmission over the internet or electronic storage is completely secure, and we cannot guarantee absolute security.\n\nYou are responsible for keeping your password confidential. Do not share your login credentials with anyone."
                )

                // Section 7
                PrivacySectionView(
                    number: "7",
                    title: "Your Rights and Choices",
                    body: "You have the following rights regarding your personal information:\n\n• Access: You may request a copy of the personal information we hold about you.\n\n• Correction: You may update or correct inaccurate information through your account settings.\n\n• Deletion: You may request that we delete your account and associated personal data.\n\n• Portability: You may request an export of your data in a commonly used format.\n\n• Opt-Out of Notifications: You can manage notification preferences within the Community settings.\n\nTo exercise any of these rights, please contact us at the address listed in Section 10. We will respond to your request within a reasonable timeframe."
                )

                // Section 8
                PrivacySectionView(
                    number: "8",
                    title: "Third-Party Links and Services",
                    body: "The Community may contain links to external websites or services not operated by us. We are not responsible for the privacy practices of those third parties. We encourage you to review the privacy policies of any external services you access."
                )

                // Section 9
                PrivacySectionView(
                    number: "9",
                    title: "Changes to This Policy",
                    body: "We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. When we make material changes, we will update the effective date at the top of this page and, where appropriate, notify you through the Community or via email. Your continued use of the Community after any changes constitutes your acceptance of the updated policy."
                )

                // Section 10
                PrivacySectionView(
                    number: "10",
                    title: "Contact Us",
                    body: "If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us:\n\nCherry Blossom Development LLC\nSpokane, Washington\nUnited States\nprivacy@cherryblossomdevelopment.com"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.greywireBg)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.greywireBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Privacy Section View

private struct PrivacySectionView<Content: View>: View {
    let number: String
    let title: String
    let content: Content

    init(number: String, title: String, @ViewBuilder content: () -> Content) {
        self.number = number
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(number). \(title)")
                .font(.greywireHeadline)
                .foregroundStyle(Color.greywireText)

            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)

            content
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
        }
    }
}

extension PrivacySectionView where Content == Text {
    init(number: String, title: String, body: String) {
        self.number = number
        self.title = title
        self.content = Text(body)
    }
}
