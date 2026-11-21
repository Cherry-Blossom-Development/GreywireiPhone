import Foundation

@MainActor
@Observable
final class ClaimPedalViewModel {
    var serial: String = ""
    var membership: MembershipResponse?
    var isClaiming: Bool = false
    var errorMessage: String?
    var claimedPedal: GreywirePedal?
    var alreadyYours: Bool = false
    var sessionExpired: Bool = false
    /// Guest accounts can never claim pedals.
    var isGuest: Bool = false

    func load() async {
        // Check if user is a guest
        let meResult = await APIClient.shared.getMe()
        switch meResult {
        case .success(let me):
            isGuest = me.isGuest ?? false
        case .error(_, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
        }

        // Load membership
        let result = await APIClient.shared.getMembership()
        switch result {
        case .success(let response):
            membership = response
        case .error(_, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            }
            // Not fatal: the form works without the list of pedals already held
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func claim() async {
        guard !isClaiming, !serial.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let normalizedSerial = Self.normalizeSerial(serial)
        let heldBefore = membership?.pedals.contains { $0.serial == normalizedSerial } ?? false

        isClaiming = true
        errorMessage = nil

        let result = await APIClient.shared.claimPedal(serial: serial)

        isClaiming = false

        switch result {
        case .success(let response):
            let newMembership = response.membership ?? membership
            let pedal = newMembership?.pedals.first { $0.serial == normalizedSerial }
                ?? GreywirePedal(id: 0, model: "Greywire pedal", serial: normalizedSerial, buildDate: nil, claimedAt: nil)
            membership = newMembership
            claimedPedal = pedal
            alreadyYours = heldBefore
        case .error(let message, let unauthorized, _):
            errorMessage = message
            if unauthorized {
                sessionExpired = true
            }
        }
    }

    /// Same rules as the backend's normalizeSerial (utilities/greywire.js), used only to find the claimed pedal.
    static func normalizeSerial(_ input: String) -> String {
        var result = input.trimmingCharacters(in: .whitespaces)
        if result.lowercased().hasPrefix("0x") {
            result = String(result.dropFirst(2))
        }
        result = result.replacingOccurrences(of: " ", with: "")
        result = result.replacingOccurrences(of: "-", with: "")
        result = result.replacingOccurrences(of: ":", with: "")
        return result.uppercased()
    }
}
