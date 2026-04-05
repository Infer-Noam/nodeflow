//
//  DataService.swift
//  nodeflow
//

import Foundation
import SwiftData

struct DataService {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
