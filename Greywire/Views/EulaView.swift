import SwiftUI

struct EulaView: View {
    @State private var showPrivacyPolicy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("End User License Agreement")
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
                Text("This End User License Agreement (\"EULA\" or \"Agreement\") is a legal agreement between you (\"User,\" \"you,\" or \"your\") and Cherry Blossom Development LLC (\"Company,\" \"we,\" \"us,\" or \"our\"), governing your use of the Greywire Studio community at community.greywirestudio.com and associated services (collectively, the \"Service\"). By creating an account or using the Service in any way, you acknowledge that you have read, understood, and agree to be bound by this Agreement. If you do not agree, do not use the Service.")
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
                EulaSectionView(number: "1", title: "Acceptance and Eligibility") {
                    Text("You must be at least ")
                    + Text("18 years of age").fontWeight(.semibold)
                    + Text(" to use the Service. By using the Service, you represent and warrant that you meet this requirement. We reserve the right to terminate any account found to belong to a minor.\n\nYour use of the Service is also subject to our ")
                    + Text("Privacy Policy").foregroundColor(Color.greywireCopper)
                    + Text(", which is incorporated into this Agreement by reference.")
                }
                .onTapGesture {
                    showPrivacyPolicy = true
                }

                // Section 2
                EulaSectionView(
                    number: "2",
                    title: "License Grant",
                    body: "Subject to your compliance with this Agreement, Cherry Blossom Development LLC grants you a limited, non-exclusive, non-transferable, revocable license to access and use the Service for your personal, non-commercial purposes. This license does not include the right to sublicense, sell, resell, transfer, assign, or otherwise exploit the Service or any of its content."
                )

                // Section 3 - Greywire-specific
                EulaSectionView(number: "3", title: "Greywire Membership") {
                    Text("The community is open to members only. Membership is free and comes with a Greywire Studio pedal: you join by claiming your pedal's serial number, or by invitation from us.\n\n")
                    + Text("One account per serial.").fontWeight(.semibold)
                    + Text(" Each serial number can be claimed by one account. Claim only a pedal you own. Claiming a serial that isn't yours, or sharing one so others can get in, is a violation of this Agreement.\n\n")
                    + Text("Membership follows the pedal.").fontWeight(.semibold)
                    + Text(" Membership belongs to the account that holds the serial. If you sell or give away your pedal, contact us and we can move the serial to the new owner's account; your account then loses membership unless you hold another pedal or an invitation.\n\n")
                    + Text("Revocation.").fontWeight(.semibold)
                    + Text(" We may revoke membership for any violation of this Agreement.\n\n")
                    + Text("The community only.").fontWeight(.semibold)
                    + Text(" Membership covers the online community. It does not change the terms or warranty of the pedal itself, and the pedal works without it.")
                }

                // Section 4 - Greywire-specific
                EulaSectionView(
                    number: "4",
                    title: "One Account for Greywire and Prosaurus",
                    body: "Your account is shared with Prosaurus (prosaurus.com), another service run by Cherry Blossom Development LLC. You sign in to both with the same username and password, and your profile, friends and direct messages are the same on both sites. Chat rooms, recordings and bands belong to the site where they were created and are not shown on the other.\n\nThis Agreement covers your account on both sites. A suspension or termination applies to the whole account."
                )

                // Section 5
                EulaSectionView(number: "5", title: "Prohibited Content - Zero Tolerance Policy") {
                    Text("We maintain a ")
                    + Text("zero-tolerance policy").fontWeight(.semibold)
                    + Text(" for objectionable content. The following types of content are strictly prohibited and will result in immediate account termination without warning or refund:\n\n")
                    + Text("• Sexually explicit or pornographic content of any kind.\n\n• Content that exploits, endangers, or sexualizes minors in any way. Such content will be reported to the NCMEC and relevant law enforcement.\n\n• Hate speech or discriminatory content targeting individuals or groups based on race, ethnicity, religion, gender, sexual orientation, disability, national origin, or any other protected characteristic.\n\n• Content that promotes, glorifies, or incites violence, self-harm, terrorism, or illegal activity.\n\n• Harassment, threats, or intimidation directed at any person or group.\n\n• Spam, misinformation, or deliberately false content intended to deceive or mislead other users.\n\n• Content that violates any applicable law, including copyright, defamation, privacy, or consumer protection laws.\n\n• Malware, phishing links, or any content designed to compromise the security of other users or systems.")
                }

                // Section 6
                EulaSectionView(number: "6", title: "Prohibited Conduct - Zero Tolerance for Abusive Users") {
                    Text("We maintain a ")
                    + Text("zero-tolerance policy").fontWeight(.semibold)
                    + Text(" for abusive behavior. The following conduct is strictly prohibited and will result in immediate and permanent account termination:\n\n• Harassment or bullying of other users, including repeated unwanted contact, public humiliation, or coordinated attacks.\n\n• Threatening or intimidating any user, employee, or person associated with the Service.\n\n• Impersonating another person, company, or entity in a misleading or harmful way.\n\n• Unauthorized access or hacking - attempting to access accounts, systems, or data that are not your own.\n\n• Circumventing or undermining security measures, including sharing login credentials or attempting to bypass account verification.\n\n• Deliberately disrupting the Service, including denial-of-service attacks, flooding, or other technically abusive behavior.\n\n• Creating multiple accounts to evade a ban or circumvent any restriction placed on your access.\n\n• Collecting or scraping user data without authorization.\n\nUsers who engage in any of the above conduct will be permanently banned. We cooperate fully with law enforcement when conduct may constitute a criminal offense.")
                }

                // Section 7
                EulaSectionView(
                    number: "7",
                    title: "Content Ownership and Responsibility",
                    body: "You retain ownership of content you create and post on the Service. By posting content, you grant Cherry Blossom Development LLC a worldwide, royalty-free, non-exclusive license to host, store, transmit, display, and distribute that content solely for the purpose of operating and improving the Service.\n\nYou are solely responsible for all content you post. We do not endorse any user-submitted content and expressly disclaim all liability arising from it."
                )

                // Section 8
                EulaSectionView(
                    number: "8",
                    title: "Reporting Violations",
                    body: "If you encounter content or behavior that violates this Agreement, please report it immediately to:\n\nabuse@cherryblossomdevelopment.com\n\nWhen content is reported or detected by our automated systems, it is immediately hidden from all users pending review. Reports submitted in good faith will be treated confidentially. We do not tolerate retaliation against users who report violations."
                )

                // Section 9
                EulaSectionView(
                    number: "9",
                    title: "Automated Content Moderation",
                    body: "To help maintain a safe environment, the Service uses automated tools to review user-submitted content for violations of this Agreement. These tools include:\n\n• Keyword filtering - content is scanned against a list of prohibited terms maintained by Cherry Blossom Development LLC.\n\n• OpenAI Moderation API - content is submitted to OpenAI's moderation service, which analyzes text for hate speech, harassment, sexual content, violence, and related categories. This processing is performed by OpenAI, L.L.C., a third-party service provider.\n\nContent flagged by either system may be automatically hidden and queued for human review. Automated moderation is not perfect - false positives can occur. If you believe your content was incorrectly removed, you may contact us at abuse@cherryblossomdevelopment.com to request a review.\n\nBy using the Service, you consent to your user-submitted content being processed by these automated systems as described above."
                )

                // Section 10
                EulaSectionView(
                    number: "10",
                    title: "Enforcement and Account Termination",
                    body: "Cherry Blossom Development LLC reserves the right to suspend or permanently terminate any account, at any time and without prior notice, for any violation of this Agreement or for any conduct we determine to be harmful.\n\nUpon termination: your license to use the Service is immediately revoked, access to your account and all associated content will be disabled, any Greywire membership on the account ends, active subscription fees are non-refundable in cases of policy violation, and we may retain records of your account and activity as required by law or for abuse prevention."
                )

                // Section 11
                EulaSectionView(
                    number: "11",
                    title: "Disclaimer of Warranties",
                    body: "The Service is provided \"as is\" and \"as available,\" without warranties of any kind, express or implied. To the fullest extent permitted by law, Cherry Blossom Development LLC disclaims all warranties, including but not limited to merchantability, fitness for a particular purpose, and non-infringement. We do not warrant that the Service will be uninterrupted, error-free, or free of viruses or other harmful components."
                )

                // Section 12
                EulaSectionView(
                    number: "12",
                    title: "Limitation of Liability",
                    body: "To the maximum extent permitted by applicable law, Cherry Blossom Development LLC and its officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the Service, even if advised of the possibility of such damages."
                )

                // Section 13
                EulaSectionView(
                    number: "13",
                    title: "Governing Law",
                    body: "This Agreement is governed by and construed in accordance with the laws of the State of Washington, United States, without regard to its conflict-of-law provisions. Any disputes arising under this Agreement shall be resolved exclusively in the state or federal courts located in Spokane County, Washington, and you consent to personal jurisdiction in those courts."
                )

                // Section 14
                EulaSectionView(
                    number: "14",
                    title: "Changes to This Agreement",
                    body: "We may update this EULA at any time. When we make material changes, we will update the effective date at the top of this page. Your continued use of the Service after any changes constitutes your acceptance of the updated Agreement. We encourage you to review this page periodically."
                )

                // Section 15
                EulaSectionView(
                    number: "15",
                    title: "Contact Us",
                    body: "If you have questions or concerns about this Agreement, please contact us:\n\nCherry Blossom Development LLC\nSpokane, Washington\nUnited States\nlegal@cherryblossomdevelopment.com"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.greywireBg)
        .navigationTitle("EULA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.greywireBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

// MARK: - EULA Section View

private struct EulaSectionView<Content: View>: View {
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

extension EulaSectionView where Content == Text {
    init(number: String, title: String, body: String) {
        self.number = number
        self.title = title
        self.content = Text(body)
    }
}
