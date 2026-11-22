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

// MARK: - Billing Models

struct BillingPlanResponse: Decodable, Sendable {
    let subscribed: Bool
    let platform: String?
    let status: String?
    let expiresAt: String?
    let feePercent: Int
    let greywire: MembershipResponse?

    enum CodingKeys: String, CodingKey {
        case subscribed, platform, status
        case expiresAt = "expires_at"
        case feePercent = "fee_percent"
        case greywire
    }
}

// MARK: - Friends Models

/// A friend in the user's friends list.
struct Friend: Decodable, Identifiable, Sendable {
    let id: Int
    let handle: String
    let firstName: String?
    let lastName: String?
    let photoPath: String?
    let friendsSince: String?
    let isOnline: Bool?

    var displayName: String {
        if let first = firstName, let last = lastName, !first.isEmpty || !last.isEmpty {
            return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        }
        return handle
    }
}

/// An incoming friend request.
struct FriendRequest: Decodable, Identifiable, Sendable {
    let id: Int
    let handle: String
    let firstName: String?
    let lastName: String?
    let photoPath: String?
    let requestedAt: String?

    var displayName: String {
        if let first = firstName, let last = lastName, !first.isEmpty || !last.isEmpty {
            return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        }
        return handle
    }
}

/// An outgoing friend request the user has sent.
struct SentFriendRequest: Decodable, Identifiable, Sendable {
    let id: Int
    let handle: String
    let firstName: String?
    let lastName: String?
    let photoPath: String?
    let requestedAt: String?

    var displayName: String {
        if let first = firstName, let last = lastName, !first.isEmpty || !last.isEmpty {
            return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        }
        return handle
    }
}

struct FriendsListResponse: Decodable, Sendable {
    let friends: [Friend]
}

struct FriendRequestsResponse: Decodable, Sendable {
    let requests: [FriendRequest]
}

struct SentRequestsResponse: Decodable, Sendable {
    let sent: [SentFriendRequest]
}

struct FriendActionResponse: Decodable, Sendable {
    let message: String?
}

// MARK: - Auth Result

enum AuthResult<T: Sendable>: Sendable {
    case success(T)
    case error(String, unauthorized: Bool = false, requiresSubscription: Bool = false)
}
