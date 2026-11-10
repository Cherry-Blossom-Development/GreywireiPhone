import SwiftUI

// Greywire palette -- taken from GreywireStudio-Website css/site.css (:root).
// Keep these in step with the website so the app and site read as one brand.

extension Color {
    // Background colors
    static let greywireBg = Color(hex: 0x141619)           // --bg
    static let greywireSurface = Color(hex: 0x1C1F23)      // --surface (cards)
    static let greywireSurface2 = Color(hex: 0x24282D)     // --surface-2
    static let greywireLine = Color(hex: 0x33383E)         // --line (borders, dividers)

    // Text colors
    static let greywireText = Color(hex: 0xE8E6E1)         // --text
    static let greywireMuted = Color(hex: 0x9BA0A6)        // --muted

    // Accent colors
    static let greywireCopper = Color(hex: 0xD07A3E)       // --copper (accent, primary buttons)
    static let greywireCopperSoft = Color(hex: 0xE9A46F)   // --copper-soft (eyebrows)
    static let greywireSignal = Color(hex: 0x5FD38A)       // --signal (positive state)
    static let greywireOnCopper = Color(hex: 0x1A1209)     // .button text color
    static let greywireError = Color(hex: 0xE5735F)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
