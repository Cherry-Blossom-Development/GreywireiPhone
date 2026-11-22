import SwiftUI
import AVKit

/// The Sessions tab showing recordings.
struct SessionsView: View {
    @State private var viewModel = SessionsViewModel()
    @State private var selectedSession: Session?
    let onSessionExpired: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                SessionsTopBar(title: "Sessions")

                // Section picker
                SessionsSectionPicker(
                    selected: $viewModel.selectedSection,
                    myCount: viewModel.mySessions.count,
                    bandCount: viewModel.bandSessions.count
                )

                // Content
                if viewModel.isLoading && viewModel.mySessions.isEmpty && viewModel.bandSessions.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(Color.greywireCopper)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: 16)

                            switch viewModel.selectedSection {
                            case .mine:
                                mySessionsContent
                            case .band:
                                bandSessionsContent
                            }

                            Spacer().frame(height: 24)
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: 632, alignment: .center)
                        .frame(maxWidth: .infinity)
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.greywireBg)
            .accessibilityIdentifier("sessions-screen")
            .navigationDestination(item: $selectedSession) { session in
                SessionDetailView(session: session, onSessionExpired: onSessionExpired)
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

    // MARK: - My Sessions Content

    @ViewBuilder
    private var mySessionsContent: some View {
        if viewModel.mySessions.isEmpty {
            emptyMySessionsCard
        } else {
            Eyebrow("\(viewModel.mySessions.count) recording\(viewModel.mySessions.count == 1 ? "" : "s")")
            Spacer().frame(height: 12)

            ForEach(viewModel.mySessions) { session in
                SessionRow(session: session, showUploader: false) {
                    selectedSession = session
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var emptyMySessionsCard: some View {
        GreywireCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No recordings yet")
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Text("Your band practices and solo takes will appear here. Upload from the web to get started.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }

    // MARK: - Band Sessions Content

    @ViewBuilder
    private var bandSessionsContent: some View {
        if viewModel.bandSessions.isEmpty {
            emptyBandSessionsCard
        } else {
            Eyebrow("\(viewModel.bandSessions.count) recording\(viewModel.bandSessions.count == 1 ? "" : "s") from bandmates")
            Spacer().frame(height: 12)

            ForEach(viewModel.bandSessions) { session in
                SessionRow(session: session, showUploader: true) {
                    selectedSession = session
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var emptyBandSessionsCard: some View {
        GreywireCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No band recordings")
                    .font(.greywireTitle)
                    .foregroundStyle(Color.greywireText)

                Text("Join a band to see recordings from your bandmates here.")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireMuted)
            }
        }
    }
}

// MARK: - Top Bar

private struct SessionsTopBar: View {
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

private struct SessionsSectionPicker: View {
    @Binding var selected: SessionsSection
    let myCount: Int
    let bandCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SessionsSection.allCases, id: \.self) { section in
                Button {
                    selected = section
                } label: {
                    HStack(spacing: 6) {
                        Text(section.label)
                            .font(.greywireBody)

                        // Count badge
                        let count = section == .mine ? myCount : bandCount
                        if count > 0 {
                            Text("\(count)")
                                .font(.plexMono(11, weight: .medium))
                                .foregroundStyle(Color.greywireBg)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(section == selected ? Color.greywireCopper : Color.greywireMuted)
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

// MARK: - Session Row

private struct SessionRow: View {
    let session: Session
    let showUploader: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GreywireCard {
                HStack(spacing: 12) {
                    // Session icon
                    Circle()
                        .fill(Color.greywireSurface2)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "waveform")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.greywireMuted)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.displayName)
                            .font(.greywireTitle)
                            .foregroundStyle(Color.greywireText)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            // Duration
                            Text(session.formattedDuration)
                                .font(.greywireMonoSmall)
                                .foregroundStyle(Color.greywireMuted)

                            // Type
                            Text(session.typeLabel)
                                .font(.greywireCaption)
                                .foregroundStyle(Color.greywireMuted)

                            // Uploader (for band sessions)
                            if showUploader, let handle = session.uploaderHandle {
                                Text("by @\(handle)")
                                    .font(.greywireCaption)
                                    .foregroundStyle(Color.greywireMuted)
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()

                    // Rating
                    if let avg = session.avgRating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(Color.greywireCopper)
                            Text(String(format: "%.1f", avg))
                                .font(.greywireMonoSmall)
                                .foregroundStyle(Color.greywireText)
                        }
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

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: Session
    let onSessionExpired: () -> Void

    @State private var viewModel: SessionDetailViewModel
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @Environment(\.dismiss) private var dismiss

    init(session: Session, onSessionExpired: @escaping () -> Void) {
        self.session = session
        self.onSessionExpired = onSessionExpired
        self._viewModel = State(initialValue: SessionDetailViewModel(session: session))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 24)

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.displayName)
                        .font(.greywireHeadline)
                        .foregroundStyle(Color.greywireText)

                    HStack(spacing: 12) {
                        StatusPill(text: session.typeLabel)

                        if let instrument = session.instrumentName {
                            StatusPill(text: instrument)
                        }

                        if let band = session.bandName {
                            StatusPill(text: band)
                        }
                    }
                }

                Spacer().frame(height: 24)

                // Player card
                GreywireCard {
                    VStack(spacing: 16) {
                        // Waveform placeholder
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.greywireSurface2)
                            .frame(height: 80)
                            .overlay {
                                Image(systemName: "waveform")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.greywireMuted.opacity(0.5))
                            }

                        // Duration
                        Text(session.formattedDuration)
                            .font(.greywireMonoSmall)
                            .foregroundStyle(Color.greywireMuted)

                        // Play button
                        Button {
                            togglePlayback()
                        } label: {
                            Circle()
                                .fill(Color.greywireCopper)
                                .frame(width: 64, height: 64)
                                .overlay {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.greywireBg)
                                        .offset(x: isPlaying ? 0 : 2)
                                }
                        }
                    }
                }

                Spacer().frame(height: 24)

                // Rating section
                SectionDivider()
                Eyebrow("Rating")
                Spacer().frame(height: 12)

                GreywireCard {
                    VStack(spacing: 16) {
                        // Current rating
                        if let avg = viewModel.avgRating {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color.greywireCopper)
                                Text(String(format: "%.1f", avg))
                                    .font(.greywireHeadline)
                                    .foregroundStyle(Color.greywireText)
                                Text("(\(viewModel.ratingCount ?? 0) rating\((viewModel.ratingCount ?? 0) == 1 ? "" : "s"))")
                                    .font(.greywireCaption)
                                    .foregroundStyle(Color.greywireMuted)
                            }
                        } else {
                            Text("No ratings yet")
                                .font(.greywireBody)
                                .foregroundStyle(Color.greywireMuted)
                        }

                        // Rating picker
                        VStack(spacing: 8) {
                            Text("Your rating")
                                .font(.greywireCaption)
                                .foregroundStyle(Color.greywireMuted)

                            HStack(spacing: 4) {
                                ForEach(1...10, id: \.self) { rating in
                                    Button {
                                        Task {
                                            if viewModel.currentRating == rating {
                                                await viewModel.rate(nil) // Clear rating
                                            } else {
                                                await viewModel.rate(rating)
                                            }
                                        }
                                    } label: {
                                        Text("\(rating)")
                                            .font(.plexMono(12, weight: .medium))
                                            .foregroundStyle(
                                                viewModel.currentRating == rating
                                                    ? Color.greywireBg
                                                    : Color.greywireMuted
                                            )
                                            .frame(width: 28, height: 28)
                                            .background(
                                                viewModel.currentRating == rating
                                                    ? Color.greywireCopper
                                                    : Color.greywireSurface2
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                    .disabled(viewModel.isRating)
                                }
                            }
                        }
                    }
                }

                Spacer().frame(height: 24)

                // Metadata section
                SectionDivider()
                Eyebrow("Details")
                Spacer().frame(height: 12)

                GreywireCard {
                    VStack(spacing: 12) {
                        if let recordedAt = session.recordedAt {
                            metadataRow(label: "Recorded", value: formatDate(recordedAt))
                        }

                        if let uploadedAt = session.uploadedAt {
                            metadataRow(label: "Uploaded", value: formatDate(uploadedAt))
                        }

                        if let uploaderHandle = session.uploaderHandle {
                            metadataRow(label: "By", value: "@\(uploaderHandle)")
                        }
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 632, alignment: .center)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greywireBg)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.greywireBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onDisappear {
            player?.pause()
        }
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired {
                onSessionExpired()
            }
        }
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
            Spacer()
            Text(value)
                .font(.greywireMonoSmall)
                .foregroundStyle(Color.greywireText)
        }
    }

    private func togglePlayback() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil {
                setupPlayer()
            }
            player?.play()
            isPlaying = true
        }
    }

    private func setupPlayer() {
        guard let url = APIClient.shared.getSessionStreamURL(id: session.id) else { return }

        // Create request with auth headers
        Task {
            if let token = await KeychainManager.shared.getToken() {
                // For authenticated streaming, we need to use AVURLAsset with headers
                let headers = [
                    "Authorization": "Bearer \(token)",
                    "Cookie": "jwtToken=\(token)"
                ]
                let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                let item = AVPlayerItem(asset: asset)
                await MainActor.run {
                    player = AVPlayer(playerItem: item)
                }
            }
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        // Try ISO8601 with time
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = isoFormatter.date(from: dateStr)
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: dateStr)
        }

        // Try date-only format (YYYY-MM-DD)
        if date == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            date = dateFormatter.date(from: dateStr)
        }

        guard let date else { return dateStr }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}
