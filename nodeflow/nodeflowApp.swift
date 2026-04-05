//
//  nodeflowApp.swift
//  nodeflow
//
//  Created by נועם נאור on 05/04/2026.
//

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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
