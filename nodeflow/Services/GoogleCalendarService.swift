import Foundation

class GoogleCalendarService {
    private let baseURL = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
    private let authService: GoogleAuthService

    enum CalendarError: LocalizedError {
        case invalidResponse
        case unauthorized(String)
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:       return "Unexpected response from Google Calendar."
            case .unauthorized(let msg): return "Google auth failed: \(msg)"
            case .httpError(let code):   return "Google Calendar API error: HTTP \(code)"
            }
        }
    }

    init(authService: GoogleAuthService) {
        self.authService = authService
    }

    func syncEvent(for flow: Flow) async throws -> String {
        let token = try await validToken()
        let body  = buildEventBody(for: flow)

        if let existingID = flow.calendarEventIdentifier {
            return try await updateEvent(id: existingID, body: body, token: token)
        } else {
            return try await createEvent(body: body, token: token)
        }
    }

    func deleteEvent(identifier: String) async throws {
        let token = try await validToken()
        let url = URL(string: "\(baseURL)/\(identifier)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 204 || status == 200 else {
            throw CalendarError.httpError(status)
        }
    }

    // MARK: - Private

    private func validToken() async throws -> String {
        if authService.accessToken == nil {
            try await authService.signIn()
        }
        guard let token = authService.accessToken else {
            throw GoogleAuthService.AuthError.notSignedIn
        }
        return token
    }

    private func createEvent(body: [String: Any], token: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await performEventRequest(request)
    }

    private func updateEvent(id: String, body: [String: Any], token: String) async throws -> String {
        var request = URLRequest(url: URL(string: "\(baseURL)/\(id)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await performEventRequest(request, retryOn401: id)
    }

    private func performEventRequest(_ request: URLRequest, retryOn401: String? = nil) async throws -> String {
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        if status == 401 {
            // Token expired — refresh and retry once
            try await authService.refreshIfNeeded()
            guard let newToken = authService.accessToken else { throw GoogleAuthService.AuthError.notSignedIn }
            var retried = request
            retried.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            let (retryData, _) = try await URLSession.shared.data(for: retried)
            return try extractEventID(from: retryData)
        }

        guard (200...299).contains(status) else { throw CalendarError.httpError(status) }
        return try extractEventID(from: data)
    }

    private func extractEventID(from data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id = json["id"] as? String
        else { throw CalendarError.invalidResponse }
        return id
    }

    private func buildEventBody(for flow: Flow) -> [String: Any] {
        let tz = TimeZone.current.identifier
        var body: [String: Any] = ["summary": flow.title]
        if let desc = eventDescription(for: flow) { body["description"] = desc }
        if flow.isRecurring { body["recurrence"] = [(flow.recurrenceFrequency ?? .daily).rruleString] }

        if let scheduledTime = flow.scheduledTime {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            let endDate = scheduledTime.addingTimeInterval(Double((flow.durationMinutes ?? 60) * 60))
            body["start"] = ["dateTime": formatter.string(from: scheduledTime), "timeZone": tz]
            body["end"]   = ["dateTime": formatter.string(from: endDate),       "timeZone": tz]
        } else {
            // All-day event for today
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let todayStr = df.string(from: Date())
            body["start"] = ["date": todayStr]
            body["end"]   = ["date": todayStr]
        }

        if let mins = flow.notificationMinutesBefore {
            body["reminders"] = [
                "useDefault": false,
                "overrides": [["method": "popup", "minutes": mins]]
            ]
        } else {
            body["reminders"] = ["useDefault": false, "overrides": [] as [[String: Any]]]
        }

        return body
    }

    private func eventDescription(for flow: Flow) -> String? {
        var parts: [String] = []
        if !flow.notes.isEmpty { parts.append(flow.notes) }
        let sorted = flow.nodes.sorted { $0.order < $1.order }
        if !sorted.isEmpty {
            let stepsHeader = parts.isEmpty ? "Steps:" : "\nSteps:"
            parts.append(stepsHeader)
            for (i, node) in sorted.enumerated() {
                let prefix = node.emoji.map { "\($0) " } ?? ""
                var line = "\(i + 1). \(prefix)\(node.title)"
                if let d = node.durationMinutes { line += " (\(d) min)" }
                parts.append(line)
            }
        }
        parts.append("\nOpen in NodeFlow: nodeflow://flow/\(flow.deepLinkID)")
        return parts.joined(separator: "\n")
    }
}
