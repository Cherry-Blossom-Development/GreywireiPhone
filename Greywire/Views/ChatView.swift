import SwiftUI

/// The Chat tab showing chat rooms and direct messages.
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var selectedRoom: ChatRoom?
    let onSessionExpired: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                ChatTopBar(title: "Chat")

                // Section picker
                ChatSectionPicker(
                    selected: $viewModel.selectedSection,
                    dmCount: viewModel.dms.count
                )

                // Content
                if viewModel.isLoading && viewModel.rooms.isEmpty && viewModel.dms.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(Color.greywireCopper)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: 16)

                            switch viewModel.selectedSection {
                            case .rooms:
                                roomsContent
                            case .dms:
                                dmsContent
                            }

                            Spacer().frame(height: 24)
                        }
                        .padding(.horizontal, 16)
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.greywireBg)
            .accessibilityIdentifier("chat-screen")
            .navigationDestination(item: $selectedRoom) { room in
                ChatRoomView(room: room, onSessionExpired: onSessionExpired)
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
    }

    // MARK: - Rooms Content

    @ViewBuilder
    private var roomsContent: some View {
        if viewModel.rooms.isEmpty {
            emptyRoomsCard
        } else {
            Eyebrow("\(viewModel.rooms.count) room\(viewModel.rooms.count == 1 ? "" : "s")")
            Spacer().frame(height: 12)

            ForEach(viewModel.rooms) { room in
                ChatRoomRow(room: room) {
                    selectedRoom = room
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var emptyRoomsCard: some View {
        GreywireCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No chat rooms yet")
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Text("Join the Greywire community to participate in chat rooms with other musicians.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }

    // MARK: - DMs Content

    @ViewBuilder
    private var dmsContent: some View {
        if viewModel.dms.isEmpty {
            emptyDMsCard
        } else {
            Eyebrow("\(viewModel.dms.count) conversation\(viewModel.dms.count == 1 ? "" : "s")")
            Spacer().frame(height: 12)

            ForEach(viewModel.dms) { dm in
                DMRow(dm: dm) {
                    selectedRoom = dm
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var emptyDMsCard: some View {
        GreywireCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No messages yet")
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Text("Start a conversation with a friend from the Friends tab.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }
}

// MARK: - Top Bar

private struct ChatTopBar: View {
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.greywireTitle)
                .foregroundStyle(Color.greywireText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)
        }
    }
}

// MARK: - Section Picker

private struct ChatSectionPicker: View {
    @Binding var selected: ChatSection
    let dmCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChatSection.allCases, id: \.self) { section in
                Button {
                    selected = section
                } label: {
                    HStack(spacing: 6) {
                        Text(section.label)
                            .font(.greywireBody)

                        // Badge for DMs
                        if section == .dms && dmCount > 0 {
                            Text("\(dmCount)")
                                .font(.plexMono(11, weight: .medium))
                                .foregroundStyle(Color.greywireBg)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.greywireCopper)
                                .clipShape(Capsule())
                        }
                    }
                    .foregroundStyle(section == selected ? Color.greywireCopper : Color.greywireMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.greywireSurface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)
        }
    }
}

// MARK: - Chat Room Row

private struct ChatRoomRow: View {
    let room: ChatRoom
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GreywireCard {
                HStack(spacing: 12) {
                    // Room icon
                    Circle()
                        .fill(Color.greywireSurface2)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.greywireMuted)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(room.displayName)
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireText)

                        if let description = room.description, !description.isEmpty {
                            Text(description)
                                .font(.greywireCaption)
                                .foregroundStyle(Color.greywireMuted)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Unread badge
                    if let unread = room.unreadCount, unread > 0 {
                        Text("\(unread)")
                            .font(.plexMono(11, weight: .medium))
                            .foregroundStyle(Color.greywireBg)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.greywireCopper)
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.greywireMuted)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DM Row

private struct DMRow: View {
    let dm: ChatRoom
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GreywireCard {
                HStack(spacing: 12) {
                    // Avatar
                    Circle()
                        .fill(Color.greywireSurface2)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text((dm.partnerHandle ?? "?").prefix(1).uppercased())
                                .font(.greywireTitle)
                                .foregroundStyle(Color.greywireMuted)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(dm.partnerHandle ?? "Unknown")
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireText)

                        if let lastMessage = dm.lastMessage {
                            Text(lastMessage)
                                .font(.greywireCaption)
                                .foregroundStyle(Color.greywireMuted)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Unread badge
                    if let unread = dm.unreadCount, unread > 0 {
                        Text("\(unread)")
                            .font(.plexMono(11, weight: .medium))
                            .foregroundStyle(Color.greywireBg)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.greywireCopper)
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.greywireMuted)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chat Room Detail View

struct ChatRoomView: View {
    let room: ChatRoom
    let onSessionExpired: () -> Void

    @State private var viewModel: ChatRoomViewModel
    @Environment(\.dismiss) private var dismiss

    init(room: ChatRoom, onSessionExpired: @escaping () -> Void) {
        self.room = room
        self.onSessionExpired = onSessionExpired
        self._viewModel = State(initialValue: ChatRoomViewModel(room: room))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Load more indicator
                        if viewModel.hasMore {
                            Button {
                                Task { await viewModel.loadMore() }
                            } label: {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(Color.greywireCopper)
                                } else {
                                    Text("Load earlier messages")
                                        .font(.greywireCaption)
                                        .foregroundStyle(Color.greywireCopper)
                                }
                            }
                            .padding(.vertical, 12)
                        }

                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            MessageInputBar(
                text: $viewModel.messageText,
                isSending: viewModel.isSending
            ) {
                Task { await viewModel.sendMessage() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .navigationTitle(room.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.greywireBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.loadMessages()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar
            Circle()
                .fill(Color.greywireSurface2)
                .frame(width: 32, height: 32)
                .overlay {
                    Text((message.handle ?? "?").prefix(1).uppercased())
                        .font(.greywireCaption)
                        .foregroundStyle(Color.greywireMuted)
                }

            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack(spacing: 8) {
                    Text(message.handle ?? "Unknown")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireCopper)

                    if let createdAt = message.createdAt {
                        Text(formatTime(createdAt))
                            .font(.greywireCaption)
                            .foregroundStyle(Color.greywireMuted)
                    }
                }

                // Message text
                if let text = message.message, !text.isEmpty {
                    Text(text)
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireText)
                }

                // Media indicator
                if message.hasMedia {
                    HStack(spacing: 4) {
                        Image(systemName: message.imagePath != nil ? "photo" : "video")
                            .font(.caption)
                        Text(message.imagePath != nil ? "Image" : "Video")
                            .font(.greywireCaption)
                    }
                    .foregroundStyle(Color.greywireMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.greywireSurface2)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            Spacer(minLength: 40)
        }
    }

    private func formatTime(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: dateStr)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateStr)
        }

        guard let date else { return "" }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter.string(from: date)
    }
}

// MARK: - Message Input Bar

private struct MessageInputBar: View {
    @Binding var text: String
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.greywireLine)
                .frame(height: 1)

            HStack(spacing: 12) {
                TextField("Message", text: $text, axis: .vertical)
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.greywireSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .lineLimit(1...5)

                Button(action: onSend) {
                    if isSending {
                        ProgressView()
                            .tint(Color.greywireCopper)
                            .frame(width: 36, height: 36)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(
                                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.greywireMuted
                                    : Color.greywireCopper
                            )
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.greywireSurface)
        }
    }
}
