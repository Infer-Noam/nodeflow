import Foundation
import SwiftData

@Model
final class Flow {
    var title: String
    var emoji: String?
    var imageData: Data?
    var notes: String
    var scheduledTime: Date?
    var durationMinutes: Int?
    var isRecurring: Bool
    var recurrenceFrequency: RecurrenceFrequency
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var nodes: [FlowNode]

    init(
        title: String,
        emoji: String? = nil,
        imageData: Data? = nil,
        notes: String = "",
        scheduledTime: Date? = nil,
        durationMinutes: Int? = nil,
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency = .daily,
        nodes: [FlowNode] = []
    ) {
        self.title = title
        self.emoji = emoji
        self.imageData = imageData
        self.notes = notes
        self.scheduledTime = scheduledTime
        self.durationMinutes = durationMinutes
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency
        self.createdAt = Date()
        self.updatedAt = Date()
        self.nodes = nodes
    }
}