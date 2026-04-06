import Foundation

enum CalendarProvider: String, Codable, CaseIterable {
    case none = "None"
    case apple = "Apple Calendar"
    case google = "Google Calendar"
}
