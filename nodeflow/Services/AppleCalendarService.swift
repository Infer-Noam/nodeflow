import EventKit
import Foundation

class AppleCalendarService {
    private let store = EKEventStore()

    enum AppleCalendarError: LocalizedError {
        case accessDenied

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Calendar access was denied. Enable it in Settings."
            }
        }
    }

    func requestAccess() async throws {
        if #available(iOS 17.0, *) {
            let granted = try await store.requestWriteOnlyAccessToEvents()
            if !granted { throw AppleCalendarError.accessDenied }
        } else {
            let granted: Bool = try await withCheckedThrowingContinuation { continuation in
                store.requestAccess(to: .event) { granted, error in
                    if let error { continuation.resume(throwing: error) }
                    else { continuation.resume(returning: granted) }
                }
            }
            if !granted { throw AppleCalendarError.accessDenied }
        }
    }

    func syncEvent(for flow: Flow) async throws -> String {
        try await requestAccess()

        let event: EKEvent
        if let identifier = flow.calendarEventIdentifier,
           let existing = store.event(withIdentifier: identifier) {
            event = existing
        } else {
            event = EKEvent(eventStore: store)
            event.calendar = store.defaultCalendarForNewEvents
        }

        event.title = flow.title
        event.notes = eventDescription(for: flow)

        if let scheduledTime = flow.scheduledTime {
            event.isAllDay = false
            event.startDate = scheduledTime
            event.endDate = scheduledTime.addingTimeInterval(TimeInterval((flow.durationMinutes ?? 60) * 60))
        } else {
            event.isAllDay = true
            event.startDate = Calendar.current.startOfDay(for: Date())
            event.endDate = event.startDate
        }

        if flow.isRecurring {
            event.recurrenceRules = [(flow.recurrenceFrequency ?? .daily).ekRecurrenceRule]
        } else {
            event.recurrenceRules = nil
        }

        event.alarms = nil
        if let mins = flow.notificationMinutesBefore {
            event.addAlarm(EKAlarm(relativeOffset: -TimeInterval(mins * 60)))
        }

        try store.save(event, span: .futureEvents)
        return event.eventIdentifier
    }

    func deleteEvent(identifier: String) throws {
        guard let event = store.event(withIdentifier: identifier) else { return }
        try store.remove(event, span: .futureEvents)
    }

    private func eventDescription(for flow: Flow) -> String? {
        var parts: [String] = []
        if !flow.notes.isEmpty { parts.append(flow.notes) }
        let sorted = flow.nodes.sorted { $0.order < $1.order }
        if !sorted.isEmpty {
            let stepsHeader = parts.isEmpty ? "Steps:" : "\nSteps:"
            parts.append(stepsHeader)
            for (i, node) in sorted.enumerated() {
                let prefix = node.emoji.map { "\($0) " } ?? ""
                var line = "\(i + 1). \(prefix)\(node.title)"
                if let d = node.durationMinutes { line += " (\(d) min)" }
                parts.append(line)
            }
        }
        parts.append("\nOpen in NodeFlow: nodeflow://flow/\(flow.deepLinkID)")
        return parts.joined(separator: "\n")
    }
}
