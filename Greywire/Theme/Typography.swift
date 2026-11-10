import SwiftUI

// Greywire typography using Space Grotesk (text) and IBM Plex Mono (labels/eyebrows)

extension Font {
    // Space Grotesk - main text font
    static func spaceGrotesk(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "SpaceGrotesk-Bold"
        case .medium, .semibold:
            fontName = "SpaceGrotesk-Medium"
        default:
            fontName = "SpaceGrotesk-Regular"
        }
        return .custom(fontName, size: size)
    }

    // IBM Plex Mono - labels and eyebrows
    static func plexMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .medium, .semibold, .bold, .heavy, .black:
            fontName = "IBMPlexMono-Medium"
        default:
            fontName = "IBMPlexMono-Regular"
        }
        return .custom(fontName, size: size)
    }

    // Convenience styles
    static let greywireDisplay = spaceGrotesk(32, weight: .bold)
    static let greywireHeadline = spaceGrotesk(24, weight: .bold)
    static let greywireTitle = spaceGrotesk(20, weight: .medium)
    static let greywireBody = spaceGrotesk(16)
    static let greywireCaption = spaceGrotesk(14)

    static let greywireEyebrow = plexMono(12, weight: .medium)
    static let greywireMonoSmall = plexMono(12)
    static let greywireLabel = plexMono(14, weight: .medium)
}
