import Foundation
import SwiftData

@Model
final class FlowNode {
    var title: String
    var emoji: String?
    var imageData: Data?
    var notes: String
    var durationMinutes: Int?
    var order: Int

    init(title: String, emoji: String? = nil, imageData: Data? = nil, notes: String = "", durationMinutes: Int? = nil, order: Int = 0) {
        self.title = title
        self.emoji = emoji
        self.imageData = imageData
        self.notes = notes
        self.durationMinutes = durationMinutes
        self.order = order
    }
}
