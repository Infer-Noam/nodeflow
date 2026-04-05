import Foundation
import SwiftData

struct DataService {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Flow.self, FlowNode.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [config])
    }
}