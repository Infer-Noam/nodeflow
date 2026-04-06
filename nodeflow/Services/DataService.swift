import Foundation
import SwiftData

struct DataService {
    static func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Flow.self, FlowNode.self)
    }
}