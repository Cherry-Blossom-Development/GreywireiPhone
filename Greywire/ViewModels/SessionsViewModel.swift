import Foundation

@MainActor
@Observable
final class SessionsViewModel {
    var mySessions: [Session] = []
    var bandSessions: [Session] = []
    var isLoading = false
    var errorMessage: String?
    var sessionExpired = false

    /// Currently selected section
    var selectedSection: SessionsSection = .mine

    var totalCount: Int {
        mySessions.count + bandSessions.count
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        // Load my sessions and band sessions in parallel
        async let myResult = APIClient.shared.getSessions()
        async let bandResult = APIClient.shared.getBandMemberSessions()

        let (mr, br) = await (myResult, bandResult)

        isLoading = false

        // Process my sessions
        switch mr {
        case .success(let response):
            mySessions = response.sessions
        case .error(let message, let unauthorized, _):
            if unauthorized {
                sessionExpired = true
                return
            }
            errorMessage = message
        }

        // Process band sessions
        switch br {
        case .success(let response):
            bandSessions = response.sessions
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

// MARK: - Session Detail ViewModel

@MainActor
@Observable
final class SessionDetailViewModel {
    let session: Session

    var currentRating: Int?
    var avgRating: Double?
    var ratingCount: Int?
    var isRating = false
    var errorMessage: String?
    var sessionExpired = false

    init(session: Session) {
        self.session = session
        self.currentRating = session.myRating
        self.avgRating = session.avgRating
        self.ratingCount = session.ratingCount
    }

    func rate(_ rating: Int?) async {
        guard !isRating else { return }

        isRating = true
        errorMessage = nil

        let result = await APIClient.shared.rateSession(id: session.id, rating: rating)

        isRating = false

        switch result {
        case .success(let response):
            currentRating = response.myRating
            avgRating = response.avgRating
            ratingCount = response.ratingCount
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

// MARK: - Sessions Section

enum SessionsSection: String, CaseIterable {
    case mine
    case band

    var label: String {
        switch self {
        case .mine: "My Sessions"
        case .band: "Band"
        }
    }
}
