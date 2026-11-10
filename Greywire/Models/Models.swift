import Foundation

// MARK: - Auth Models

struct LoginRequest: Encodable, Sendable {
    let handle: String
    let password: String
}

struct LoginResponse: Decodable, Sendable {
    let message: String?
    let token: String?
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

// MARK: - Auth Result

enum AuthResult<T: Sendable>: Sendable {
    case success(T)
    case error(String, unauthorized: Bool = false)
}
