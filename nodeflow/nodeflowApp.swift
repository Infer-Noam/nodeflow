
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

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
