
import SwiftUI
import SwiftData

@main
struct nodeflowApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try DataService.makeContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    let calendarSync = CalendarSyncService(googleClientID: GoogleOAuthConfig.clientID)

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(calendarSync)
        }
        .modelContainer(sharedModelContainer)
    }
}
