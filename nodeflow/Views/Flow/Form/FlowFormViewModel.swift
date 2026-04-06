import Foundation
import SwiftData

@Observable
class FlowFormViewModel {
    struct NodeDraft: Identifiable {
        let id = UUID()
        var title: String
        var emoji: String
        var notes: String
        var duration: Int?
        var imageData: Data?
    }

    var title = ""
    var notes = ""
    var hasDuration = false
    var durationMinutes = 30
    var calendarProvider: CalendarProvider = .none
    var hasScheduledTime = false
    var scheduledTime = Date()
    var isRecurring = false
    var recurrenceFrequency: RecurrenceFrequency = .daily
    var hasNotification = false
    var notificationMinutesBefore = 0

    var flowEmoji = ""
    var flowImageData: Data? = nil
    var nodes: [NodeDraft] = []

    var titleError = false

    let existingFlow: Flow?
    var isEditing: Bool { existingFlow != nil }

    init(existingFlow: Flow? = nil) {
        self.existingFlow = existingFlow
    }

    func loadExisting() {
        guard let flow = existingFlow else { return }
        title = flow.title
        notes = flow.notes
        if let d = flow.durationMinutes { hasDuration = true; durationMinutes = d }
        calendarProvider = flow.calendarProvider
        if let t = flow.scheduledTime { hasScheduledTime = true; scheduledTime = t }
        isRecurring = flow.isRecurring
        recurrenceFrequency = flow.recurrenceFrequency ?? .daily
        hasNotification = flow.notificationMinutesBefore != nil
        if let mins = flow.notificationMinutesBefore { notificationMinutesBefore = mins }
        flowEmoji = flow.emoji ?? ""
        flowImageData = flow.imageData
        nodes = flow.nodes.sorted { $0.order < $1.order }.map {
            NodeDraft(title: $0.title, emoji: $0.emoji ?? "", notes: $0.notes, duration: $0.durationMinutes, imageData: $0.imageData)
        }
    }

    func trySave(
        context: ModelContext,
        calendarSync: CalendarSyncService,
        focusTitle: () -> Void,
        onSuccess: () -> Void
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            titleError = true
            focusTitle()
            return
        }
        save(context: context, calendarSync: calendarSync, onSuccess: onSuccess)
    }

    private func save(context: ModelContext, calendarSync: CalendarSyncService, onSuccess: () -> Void) {
        let flow = existingFlow ?? Flow(title: "")

        // Capture old calendar state before overwriting
        let oldProvider   = existingFlow?.calendarProvider
        let oldIdentifier = existingFlow?.calendarEventIdentifier

        flow.title = title.trimmingCharacters(in: .whitespaces)
        flow.notes = notes
        flow.scheduledTime = (calendarProvider != .none && hasScheduledTime) ? scheduledTime : nil
        flow.durationMinutes = hasDuration ? durationMinutes : nil
        flow.isRecurring = calendarProvider != .none ? isRecurring : false
        flow.recurrenceFrequency = recurrenceFrequency
        flow.calendarProvider = calendarProvider
        flow.notificationMinutesBefore = (hasNotification && calendarProvider != .none) ? notificationMinutesBefore : nil
        flow.emoji = flowEmoji.isEmpty ? nil : flowEmoji
        flow.imageData = flowImageData
        flow.updatedAt = Date()
        flow.nodes.forEach { context.delete($0) }
        flow.nodes = nodes.enumerated().map { position, draft in
            FlowNode(title: draft.title, emoji: draft.emoji.isEmpty ? nil : draft.emoji, imageData: draft.imageData, notes: draft.notes, durationMinutes: draft.duration, order: position)
        }
        if existingFlow == nil { context.insert(flow) }

        Task {
            // If provider changed or switched to none, delete the old calendar event first
            let providerChanged = oldProvider != nil && oldProvider != calendarProvider
            if let id = oldIdentifier, let old = oldProvider, (providerChanged || calendarProvider == .none) {
                await calendarSync.deleteEvent(identifier: id, provider: old)
                flow.calendarEventIdentifier = nil
            }
            // Sync with new provider (no-op if .none)
            await calendarSync.sync(flow: flow)
        }
        onSuccess()
    }
}
