import Foundation

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
}
