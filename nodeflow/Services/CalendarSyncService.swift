import Foundation

@Observable
@MainActor
class CalendarSyncService {
    let appleCalendar  = AppleCalendarService()
    let googleAuth:      GoogleAuthService
    let googleCalendar:  GoogleCalendarService

    var syncError: String? = nil
    var isSyncing = false

    var isGoogleSignedIn: Bool { googleAuth.isSignedIn }

    init(googleClientID: String) {
        googleAuth     = GoogleAuthService(clientID: googleClientID)
        googleCalendar = GoogleCalendarService(authService: googleAuth)
    }

    func sync(flow: Flow) async {
        guard flow.calendarProvider != .none else { return }
        isSyncing = true
        syncError = nil
        defer { isSyncing = false }

        do {
            let eventID: String
            switch flow.calendarProvider {
            case .apple:
                eventID = try await appleCalendar.syncEvent(for: flow)
            case .google:
                eventID = try await googleCalendar.syncEvent(for: flow)
            case .none:
                return
            }
            flow.calendarEventIdentifier = eventID
        } catch {
            syncError = error.localizedDescription
        }
    }

    func remove(flow: Flow) async {
        guard let identifier = flow.calendarEventIdentifier else { return }
        await deleteEvent(identifier: identifier, provider: flow.calendarProvider)
        flow.calendarEventIdentifier = nil
    }

    func deleteEvent(identifier: String, provider: CalendarProvider) async {
        do {
            switch provider {
            case .apple:
                try appleCalendar.deleteEvent(identifier: identifier)
            case .google:
                try await googleCalendar.deleteEvent(identifier: identifier)
            case .none:
                break
            }
        } catch {
            syncError = error.localizedDescription
        }
    }

    func signInToGoogle() async {
        do {
            try await googleAuth.signIn()
        } catch {
            syncError = error.localizedDescription
        }
    }

    func signOutOfGoogle() {
        googleAuth.signOut()
    }
}
