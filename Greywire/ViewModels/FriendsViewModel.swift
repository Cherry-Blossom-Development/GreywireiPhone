import Foundation

@MainActor
@Observable
final class FriendsViewModel {
    var friends: [Friend] = []
    var requests: [FriendRequest] = []
    var sentRequests: [SentFriendRequest] = []

    var isLoading = false
    var errorMessage: String?
    var sessionExpired = false

    /// Currently selected section
    var selectedSection: FriendsSection = .friends

    /// Count of pending incoming requests (for badge)
    var requestCount: Int { requests.count }

    func load() async {
        isLoading = true
        errorMessage = nil

        // Load all data in parallel
        async let friendsResult = APIClient.shared.getFriends()
        async let requestsResult = APIClient.shared.getFriendRequests()
        async let sentResult = APIClient.shared.getSentRequests()

        let (fr, rr, sr) = await (friendsResult, requestsResult, sentResult)

        isLoading = false

        // Process friends
        switch fr {
        case .success(let response):
            friends = response.friends
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            errorMessage = message
        }

        // Process incoming requests
        switch rr {
        case .success(let response):
            requests = response.requests
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            if errorMessage == nil { errorMessage = message }
        }

        // Process sent requests
        switch sr {
        case .success(let response):
            sentRequests = response.sent
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            if errorMessage == nil { errorMessage = message }
        }

        // Mark requests as seen
        let _ = await APIClient.shared.markFriendRequestsSeen()
    }

    func acceptRequest(_ request: FriendRequest) async {
        let result = await APIClient.shared.acceptFriendRequest(userId: request.id)

        switch result {
        case .success:
            // Move from requests to friends
            requests.removeAll { $0.id == request.id }
            let newFriend = Friend(
                id: request.id,
                handle: request.handle,
                firstName: request.firstName,
                lastName: request.lastName,
                photoPath: request.photoPath,
                friendsSince: ISO8601DateFormatter().string(from: Date()),
                isOnline: nil
            )
            friends.insert(newFriend, at: 0)
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func declineRequest(_ request: FriendRequest) async {
        let result = await APIClient.shared.declineFriendRequest(userId: request.id)

        switch result {
        case .success:
            requests.removeAll { $0.id == request.id }
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func cancelSentRequest(_ request: SentFriendRequest) async {
        let result = await APIClient.shared.cancelFriendRequest(userId: request.id)

        switch result {
        case .success:
            sentRequests.removeAll { $0.id == request.id }
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func removeFriend(_ friend: Friend) async {
        let result = await APIClient.shared.removeFriend(userId: friend.id)

        switch result {
        case .success:
            friends.removeAll { $0.id == friend.id }
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Friends Section

enum FriendsSection: String, CaseIterable {
    case friends
    case requests

    var label: String {
        switch self {
        case .friends: "Friends"
        case .requests: "Requests"
        }
    }
}
