import Foundation
import CryptoKit

// MARK: - Auth Models

struct LoginRequest: Encodable, Sendable {
    let handle: String
    let password: String
}

struct LoginResponse: Decodable, Sendable {
    let message: String?
    let token: String?
}

struct SignupRequest: Encodable, Sendable {
    let handle: String
    let first_name: String
    let last_name: String
    let email: String
    let hash: String
    let salt: String
}

struct ForgotPasswordRequest: Encodable, Sendable {
    let email: String
}

struct MeResponse: Decodable, Sendable {
    let username: String
    let userId: Int
    let isGuest: Bool?
    let greywireMember: Bool?
}

struct ErrorResponse: Decodable, Sendable {
    let message: String?
}

// MARK: - Password Hashing

/// Password hashing matching the Prosaurus app and website (SignupForm.vue).
/// Generates a random salt, then hashes SHA-256(password + salt).
enum PasswordHasher {
    static func generateSalt() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    static func hashPassword(_ password: String, salt: String) -> String {
        let data = Data((password + salt).utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Greywire Models

struct GreywirePedal: Decodable, Identifiable, Sendable {
    let id: Int
    let model: String
    let serial: String
    let buildDate: String?
    let claimedAt: String?
}

struct MembershipResponse: Decodable, Sendable {
    let member: Bool
    let grantedAt: String?
    let pedals: [GreywirePedal]

    init(member: Bool = false, grantedAt: String? = nil, pedals: [GreywirePedal] = []) {
        self.member = member
        self.grantedAt = grantedAt
        self.pedals = pedals
    }
}

struct ClaimPedalRequest: Encodable, Sendable {
    let serial: String
}

struct ClaimPedalResponse: Decodable, Sendable {
    let message: String?
    let membership: MembershipResponse?
}

// MARK: - EULA Models

struct EulaStatusResponse: Decodable, Sendable {
    let accepted: Bool
    let notificationId: Int?
    let acceptedAt: String?
}

struct EulaAcceptResponse: Decodable, Sendable {
    let accepted: Bool
}

// MARK: - Auth Result

enum AuthResult<T: Sendable>: Sendable {
    case success(T)
    case error(String, unauthorized: Bool = false)
}
