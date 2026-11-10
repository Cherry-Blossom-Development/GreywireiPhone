import Foundation

/// HTTP client for Greywire API calls.
/// Same backend as Prosaurus (Breakroom), using the same auth mechanism.
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - Public Methods

    func login(handle: String, password: String) async -> AuthResult<LoginResponse> {
        let body = LoginRequest(handle: handle, password: password)
        return await post("/api/auth/login", body: body)
    }

    func getMe() async -> AuthResult<MeResponse> {
        await get("/api/auth/me", authenticated: true)
    }

    func getMembership() async -> AuthResult<MembershipResponse> {
        await get("/api/greywire/membership", authenticated: true)
    }

    func logout() async {
        let _: AuthResult<EmptyResponse> = await post("/api/auth/logout", body: EmptyBody(), authenticated: true)
    }

    // MARK: - HTTP Methods

    private func get<T: Decodable>(_ path: String, authenticated: Bool = false) async -> AuthResult<T> {
        await request(path, method: "GET", body: nil as EmptyBody?, authenticated: authenticated)
    }

    private func post<T: Decodable, B: Encodable>(_ path: String, body: B, authenticated: Bool = false) async -> AuthResult<T> {
        await request(path, method: "POST", body: body, authenticated: authenticated)
    }

    private func request<T: Decodable, B: Encodable>(
        _ path: String,
        method: String,
        body: B?,
        authenticated: Bool
    ) async -> AuthResult<T> {
        guard let url = URL(string: Config.baseURL + path) else {
            return .error("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios", forHTTPHeaderField: "X-Client-Platform")

        // Add auth headers if needed
        if authenticated {
            if let bearerToken = await KeychainManager.shared.getBearerToken() {
                request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
            }
            if let token = await KeychainManager.shared.getToken() {
                request.setValue("jwtToken=\(token)", forHTTPHeaderField: "Cookie")
            }
        }

        // Encode body if present
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return .error("Failed to encode request body")
            }
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .error("Invalid response")
            }

            // Check for token refresh
            if let newToken = httpResponse.value(forHTTPHeaderField: "X-New-Token") {
                await KeychainManager.shared.saveToken(newToken)
            }

            // Check status code
            if httpResponse.statusCode == 401 {
                return .error("Unauthorized", unauthorized: true)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data),
                   let message = errorResponse.message {
                    return .error(message)
                }
                return .error("Request failed with status \(httpResponse.statusCode)")
            }

            // Decode response
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)

        } catch {
            return .error(error.localizedDescription)
        }
    }
}

// MARK: - Helper Types

private struct EmptyBody: Encodable {}
private struct EmptyResponse: Decodable {}
