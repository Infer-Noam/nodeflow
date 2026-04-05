import Foundation
import SwiftData

@Observable
class FlowFormViewModel {
    struct NodeDraft {
        var title: String
        var emoji: String
        var notes: String
        var duration: Int?
        var imageData: Data?
    }

    var title = ""
    var notes = ""
    var hasScheduledTime = false
    var scheduledTime = Date()
    var hasDuration = false
    var durationMinutes = 30
    var isRecurring = false
    var recurrenceFrequency: RecurrenceFrequency = .daily

    var flowEmoji = ""
    var flowImageData: Data? = nil
    var nodes: [NodeDraft] = []
    var newNodeTitle = ""
    var newNodeEmoji = ""
    var newNodeImageData: Data? = nil
    var newNodeNotes = ""
    var newNodeDuration = ""

    var titleError = false
    var nodeTitleError = false

    let existingFlow: Flow?
    var isEditing: Bool { existingFlow != nil }

    init(existingFlow: Flow? = nil) {
        self.existingFlow = existingFlow
    }

    func loadExisting() {
        guard let flow = existingFlow else { return }
        title = flow.title
        notes = flow.notes
        isRecurring = flow.isRecurring
        if let t = flow.scheduledTime { hasScheduledTime = true; scheduledTime = t }
        if let d = flow.durationMinutes { hasDuration = true; durationMinutes = d }
        recurrenceFrequency = flow.recurrenceFrequency
        flowEmoji = flow.emoji ?? ""
        flowImageData = flow.imageData
        nodes = flow.nodes.sorted { $0.order < $1.order }.map {
            NodeDraft(title: $0.title, emoji: $0.emoji ?? "", notes: $0.notes, duration: $0.durationMinutes, imageData: $0.imageData)
        }
    }

    func commitPendingNode() {
        let trimmed = newNodeTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        nodes.append(NodeDraft(title: trimmed, emoji: newNodeEmoji, notes: newNodeNotes, duration: Int(newNodeDuration), imageData: newNodeImageData))
        newNodeTitle = ""
        newNodeEmoji = ""
        newNodeImageData = nil
        newNodeNotes = ""
        newNodeDuration = ""
    }

    func trySave(context: ModelContext, focusTitle: () -> Void, onSuccess: () -> Void) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            titleError = true
            focusTitle()
            return
        }
        commitPendingNode()
        save(context: context, onSuccess: onSuccess)
    }

    private func save(context: ModelContext, onSuccess: () -> Void) {
        let flow = existingFlow ?? Flow(title: "")
        flow.title = title.trimmingCharacters(in: .whitespaces)
        flow.notes = notes
        flow.scheduledTime = hasScheduledTime ? scheduledTime : nil
        flow.durationMinutes = hasDuration ? durationMinutes : nil
        flow.isRecurring = isRecurring
        flow.recurrenceFrequency = recurrenceFrequency
        flow.emoji = flowEmoji.isEmpty ? nil : flowEmoji
        flow.imageData = flowImageData
        flow.updatedAt = Date()
        flow.nodes.forEach { context.delete($0) }
        flow.nodes = nodes.enumerated().map { position, draft in
            FlowNode(title: draft.title, emoji: draft.emoji.isEmpty ? nil : draft.emoji, imageData: draft.imageData, notes: draft.notes, durationMinutes: draft.duration, order: position)
        }
        if existingFlow == nil { context.insert(flow) }
        onSuccess()
    }
}
