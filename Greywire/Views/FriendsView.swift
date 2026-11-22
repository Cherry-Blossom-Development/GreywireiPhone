import SwiftUI

/// The Friends tab showing the user's friends list and friend requests.
struct FriendsView: View {
    @State private var viewModel = FriendsViewModel()
    let onSessionExpired: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with title
            FriendsTopBar(title: "Friends")

            // Section picker
            FriendsSectionPicker(
                selected: $viewModel.selectedSection,
                requestCount: viewModel.requestCount
            )

            // Content
            if viewModel.isLoading && viewModel.friends.isEmpty {
                Spacer()
                ProgressView()
                    .tint(Color.greywireCopper)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 16)

                        switch viewModel.selectedSection {
                        case .friends:
                            friendsListContent
                        case .requests:
                            requestsContent
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
        .accessibilityIdentifier("friends-screen")
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
    }

    // MARK: - Friends List Content

    @ViewBuilder
    private var friendsListContent: some View {
        if viewModel.friends.isEmpty {
            emptyFriendsCard
        } else {
            Eyebrow("\(viewModel.friends.count) friend\(viewModel.friends.count == 1 ? "" : "s")")
            Spacer().frame(height: 12)

            ForEach(viewModel.friends) { friend in
                FriendRow(friend: friend) {
                    Task { await viewModel.removeFriend(friend) }
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var emptyFriendsCard: some View {
        GreywireCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No friends yet")
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Text("Other Greywire musicians will show up here once you connect. Check the Requests tab to see who wants to be friends.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }

    // MARK: - Requests Content

    @ViewBuilder
    private var requestsContent: some View {
        // Incoming requests
        if !viewModel.requests.isEmpty {
            Eyebrow("Incoming")
            Spacer().frame(height: 12)

            ForEach(viewModel.requests) { request in
                IncomingRequestRow(request: request) {
                    Task { await viewModel.acceptRequest(request) }
                } onDecline: {
                    Task { await viewModel.declineRequest(request) }
                }
                .padding(.bottom, 8)
            }

            Spacer().frame(height: 24)
        }

        // Sent requests
        if !viewModel.sentRequests.isEmpty {
            Eyebrow("Sent")
            Spacer().frame(height: 12)

            ForEach(viewModel.sentRequests) { request in
                SentRequestRow(request: request) {
                    Task { await viewModel.cancelSentRequest(request) }
                }
                .padding(.bottom, 8)
            }
        }

        // Empty state
        if viewModel.requests.isEmpty && viewModel.sentRequests.isEmpty {
            GreywireCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No pending requests")
                        .font(.greywireTitle)
                        .foregroundStyle(Color.greywireText)

                    Text("When someone sends you a friend request, it will appear here.")
                        .font(.greywireBody)
                        .foregroundStyle(Color.greywireMuted)
                }
            }
        }
    }
}

// MARK: - Top Bar

private struct FriendsTopBar: View {
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

private struct FriendsSectionPicker: View {
    @Binding var selected: FriendsSection
    let requestCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(FriendsSection.allCases, id: \.self) { section in
                Button {
                    selected = section
                } label: {
                    HStack(spacing: 6) {
                        Text(section.label)
                            .font(.greywireBody)

                        // Badge for requests
                        if section == .requests && requestCount > 0 {
                            Text("\(requestCount)")
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

// MARK: - Friend Row

private struct FriendRow: View {
    let friend: Friend
    let onRemove: () -> Void

    @State private var showRemoveConfirm = false

    var body: some View {
        GreywireCard {
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.greywireSurface2)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(friend.handle.prefix(1).uppercased())
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireMuted)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        // Online indicator
                        if friend.isOnline == true {
                            Circle()
                                .fill(Color.greywireSignal)
                                .frame(width: 12, height: 12)
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.greywireSurface, lineWidth: 2)
                                }
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.displayName)
                        .font(.greywireTitle)
                        .foregroundStyle(Color.greywireText)

                    Text("@\(friend.handle)")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireMuted)
                }

                Spacer()

                // Remove button
                Button {
                    showRemoveConfirm = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(Color.greywireMuted)
                        .padding(8)
                }
            }
        }
        .confirmationDialog("Remove friend?", isPresented: $showRemoveConfirm) {
            Button("Remove \(friend.handle)", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can send them a friend request again later.")
        }
    }
}

// MARK: - Incoming Request Row

private struct IncomingRequestRow: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        GreywireCard {
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.greywireSurface2)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(request.handle.prefix(1).uppercased())
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireMuted)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(request.displayName)
                        .font(.greywireTitle)
                        .foregroundStyle(Color.greywireText)

                    Text("@\(request.handle)")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireMuted)
                }

                Spacer()

                // Accept/Decline buttons
                HStack(spacing: 8) {
                    Button {
                        onDecline()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.greywireMuted)
                            .frame(width: 32, height: 32)
                            .background(Color.greywireSurface2)
                            .clipShape(Circle())
                    }

                    Button {
                        onAccept()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.greywireBg)
                            .frame(width: 32, height: 32)
                            .background(Color.greywireCopper)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .accessibilityIdentifier("friend-request-\(request.id)")
    }
}

// MARK: - Sent Request Row

private struct SentRequestRow: View {
    let request: SentFriendRequest
    let onCancel: () -> Void

    @State private var showCancelConfirm = false

    var body: some View {
        GreywireCard {
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.greywireSurface2)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(request.handle.prefix(1).uppercased())
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireMuted)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(request.displayName)
                        .font(.greywireTitle)
                        .foregroundStyle(Color.greywireText)

                    Text("@\(request.handle)")
                        .font(.greywireMonoSmall)
                        .foregroundStyle(Color.greywireMuted)
                }

                Spacer()

                // Pending indicator + cancel
                HStack(spacing: 8) {
                    StatusPill(text: "Pending")

                    Button {
                        showCancelConfirm = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(Color.greywireMuted)
                            .padding(8)
                    }
                }
            }
        }
        .confirmationDialog("Cancel request?", isPresented: $showCancelConfirm) {
            Button("Cancel request", role: .destructive) {
                onCancel()
            }
            Button("Keep", role: .cancel) {}
        }
    }
}
