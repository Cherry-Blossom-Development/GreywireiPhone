import Foundation

@MainActor
@Observable
final class ChatViewModel {
    var rooms: [ChatRoom] = []
    var dms: [ChatRoom] = []
    var isLoading = false
    var errorMessage: String?
    var sessionExpired = false

    /// Currently selected section
    var selectedSection: ChatSection = .rooms

    /// Total unread count across all rooms and DMs
    var totalUnreadCount: Int {
        let roomUnread = rooms.compactMap(\.unreadCount).reduce(0, +)
        let dmUnread = dms.compactMap(\.unreadCount).reduce(0, +)
        return roomUnread + dmUnread
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        // Load rooms and DMs in parallel
        async let roomsResult = APIClient.shared.getChatRooms()
        async let dmsResult = APIClient.shared.getDirectMessages()

        let (rr, dr) = await (roomsResult, dmsResult)

        isLoading = false

        // Process rooms
        switch rr {
        case .success(let response):
            rooms = response.rooms
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            errorMessage = message
        }

        // Process DMs
        switch dr {
        case .success(let response):
            dms = response.dms
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            if errorMessage == nil { errorMessage = message }
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Chat Room Detail ViewModel

@MainActor
@Observable
final class ChatRoomViewModel {
    let room: ChatRoom

    var messages: [ChatMessage] = []
    var isLoading = false
    var isSending = false
    var hasMore = true
    var errorMessage: String?
    var sessionExpired = false

    var messageText = ""

    init(room: ChatRoom) {
        self.room = room
    }

    func loadMessages() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        let result = await APIClient.shared.getChatMessages(roomId: room.id)

        isLoading = false

        switch result {
        case .success(let response):
            messages = response.messages.reversed() // API returns newest first
            hasMore = response.hasMore ?? false
            // Mark as read
            let _ = await APIClient.shared.markChatRoomRead(roomId: room.id)
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func loadMore() async {
        guard !isLoading, hasMore, let oldest = messages.first else { return }

        isLoading = true

        let result = await APIClient.shared.getChatMessages(
            roomId: room.id,
            before: oldest.createdAt
        )

        isLoading = false

        switch result {
        case .success(let response):
            let olderMessages = response.messages.reversed()
            messages.insert(contentsOf: olderMessages, at: 0)
            hasMore = response.hasMore ?? false
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
            } else {
                errorMessage = message
            }
        }
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        isSending = true
        errorMessage = nil

        let result = await APIClient.shared.sendChatMessage(roomId: room.id, message: text)

        isSending = false

        switch result {
        case .success(let newMessage):
            messages.append(newMessage)
            messageText = ""
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

// MARK: - Chat Section

enum ChatSection: String, CaseIterable {
    case rooms
    case dms

    var label: String {
        switch self {
        case .rooms: "Rooms"
        case .dms: "Messages"
        }
    }
}
