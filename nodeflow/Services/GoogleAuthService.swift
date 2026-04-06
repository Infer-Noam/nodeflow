import AuthenticationServices
import Foundation

@Observable
@MainActor
class GoogleAuthService: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let clientID: String
    private let redirectScheme: String

    private enum Keys {
        static let accessToken  = "google_access_token"
        static let refreshToken = "google_refresh_token"
    }

    private(set) var accessToken: String? {
        get { UserDefaults.standard.string(forKey: Keys.accessToken) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.accessToken) }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: Keys.refreshToken) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.refreshToken) }
    }

    var isSignedIn: Bool { accessToken != nil }

    enum AuthError: LocalizedError {
        case notConfigured
        case cancelled
        case noCode
        case notSignedIn

        var errorDescription: String? {
            switch self {
            case .notConfigured: return "Google OAuth is not configured. Update GoogleOAuthConfig.swift."
            case .cancelled:     return "Google sign-in was cancelled."
            case .noCode:        return "No authorization code returned."
            case .notSignedIn:   return "Not signed in to Google."
            }
        }
    }

    init(clientID: String) {
        self.clientID = clientID
        let base = clientID.replacingOccurrences(of: ".apps.googleusercontent.com", with: "")
        self.redirectScheme = "com.googleusercontent.apps.\(base)"
        super.init()
    }

    func signIn() async throws {
        guard GoogleOAuthConfig.isConfigured else { throw AuthError.notConfigured }

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        let redirectURI = "\(redirectScheme):/oauth2callback"
        components.queryItems = [
            URLQueryItem(name: "client_id",     value: clientID),
            URLQueryItem(name: "redirect_uri",  value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope",         value: "https://www.googleapis.com/auth/calendar.events"),
            URLQueryItem(name: "access_type",   value: "offline"),
            URLQueryItem(name: "prompt",        value: "consent")
        ]

        let code: String = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: components.url!, callbackURLScheme: redirectScheme) { callbackURL, error in
                if let error {
                    let nsError = error as NSError
                    if nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: AuthError.cancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let callbackURL,
                      let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value
                else {
                    continuation.resume(throwing: AuthError.noCode)
                    return
                }
                continuation.resume(returning: code)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }

        try await exchangeCode(code)
    }

    func refreshIfNeeded() async throws {
        guard let refreshToken else { throw AuthError.notSignedIn }

        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            "refresh_token=\(refreshToken)",
            "client_id=\(clientID)",
            "grant_type=refresh_token"
        ].joined(separator: "&").data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = response.access_token
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.refreshToken)
    }

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first ?? ASPresentationAnchor()
    }

    private func exchangeCode(_ code: String) async throws {
        let redirectURI = "\(redirectScheme):/oauth2callback"
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            "code=\(code)",
            "client_id=\(clientID)",
            "redirect_uri=\(redirectURI)",
            "grant_type=authorization_code"
        ].joined(separator: "&").data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = response.access_token
        if let refresh = response.refresh_token { refreshToken = refresh }
    }

    private struct TokenResponse: Codable {
        let access_token: String
        let refresh_token: String?
        let expires_in: Int
    }
}
