import SwiftUI

// SwiftUI versions of the website's building blocks (GreywireStudio-Website css/site.css)

// MARK: - Brand

/// `.brand`: the logo plus "Greywire Studio", with "Studio" in muted.
struct GreywireBrand: View {
    var logoSize: CGFloat = 32
    var textSize: CGFloat = 17

    var body: some View {
        HStack(spacing: 10) {
            Image("greywire_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize, height: logoSize)

            HStack(spacing: 0) {
                Text("Greywire ")
                    .font(.spaceGrotesk(textSize, weight: .bold))
                    .foregroundStyle(Color.greywireText)
                Text("Studio")
                    .font(.spaceGrotesk(textSize))
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }
}

// MARK: - Header

/// `.site-header`: brand on the left, an optional action on the right, a line underneath.
struct GreywireHeader<Action: View>: View {
    @ViewBuilder let action: () -> Action

    init(@ViewBuilder action: @escaping () -> Action = { EmptyView() }) {
        self.action = action
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                GreywireBrand()
                Spacer()
                action()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)
        }
    }
}

// MARK: - Eyebrow

/// `.eyebrow`: small copper mono caps above a heading.
struct Eyebrow: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(.greywireEyebrow)
            .foregroundStyle(Color.greywireCopperSoft)
            .kerning(1.5)
            .padding(.bottom, 10)
    }
}

// MARK: - Section Heading

/// A section heading, styled as a heading for accessibility.
struct SectionHeading: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.greywireHeadline)
            .foregroundStyle(Color.greywireText)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Card

/// `.card`: surface background, 1px line border, 10px radius, 24px padding.
struct GreywireCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.greywireSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.greywireLine, lineWidth: 1)
        )
    }
}

// MARK: - Status Pill

/// `.status`: a pill with a colored dot and mono caps.
struct StatusPill: View {
    let text: String
    var dotColor: Color = .greywireCopper

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)

            Text(text.uppercased())
                .font(.plexMono(11, weight: .medium))
                .foregroundStyle(Color.greywireMuted)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .overlay(
            Capsule()
                .strokeBorder(Color.greywireLine, lineWidth: 1)
        )
    }
}

// MARK: - Buttons

/// `.button`: copper pill with dark text.
struct GreywireButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(Color.greywireOnCopper)
                } else {
                    Text(title)
                        .font(.spaceGrotesk(16, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(GreywireButtonStyle())
        .disabled(!isEnabled || isLoading)
    }
}

struct GreywireButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.greywireOnCopper)
            .background(
                Capsule()
                    .fill(Color.greywireCopper.opacity(isEnabled ? 1.0 : 0.5))
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

/// `.button.ghost`: transparent pill with a line border.
struct GreywireGhostButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.spaceGrotesk(14, weight: .medium))
                .padding(.horizontal, 16)
                .frame(height: 40)
        }
        .buttonStyle(GreywireGhostButtonStyle())
        .disabled(!isEnabled)
    }
}

struct GreywireGhostButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.greywireText.opacity(isEnabled ? 1.0 : 0.5))
            .background(
                Capsule()
                    .strokeBorder(Color.greywireLine, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Text Field

/// Greywire-styled text field with copper focus.
struct GreywireTextField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false
    var isEnabled: Bool = true
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.greywireCaption)
                .foregroundStyle(isFocused ? Color.greywireCopper : Color.greywireMuted)

            HStack {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.greywireBody)
                .foregroundStyle(Color.greywireText)
                .focused($isFocused)
                .disabled(!isEnabled)

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(Color.greywireMuted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.greywireSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isFocused ? Color.greywireCopper : Color.greywireLine, lineWidth: 1)
            )
        }
    }
}

// MARK: - Section Divider

struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.greywireLine)
            .frame(height: 1)
            .padding(.bottom, 32)
    }
}
