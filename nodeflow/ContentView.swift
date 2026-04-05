//
//  ContentView.swift
//  nodeflow
//
//  Created by נועם נאור on 05/04/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
