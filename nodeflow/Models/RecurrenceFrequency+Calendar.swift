import EventKit

extension RecurrenceFrequency {
    var rruleString: String {
        switch self {
        case .daily:     return "RRULE:FREQ=DAILY"
        case .weekdays:  return "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
        case .weekly:    return "RRULE:FREQ=WEEKLY"
        case .biweekly:  return "RRULE:FREQ=WEEKLY;INTERVAL=2"
        case .monthly:   return "RRULE:FREQ=MONTHLY"
        }
    }

    var ekRecurrenceRule: EKRecurrenceRule {
        switch self {
        case .daily:
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case .weekdays:
            let days = [EKRecurrenceDayOfWeek(.monday), EKRecurrenceDayOfWeek(.tuesday),
                        EKRecurrenceDayOfWeek(.wednesday), EKRecurrenceDayOfWeek(.thursday),
                        EKRecurrenceDayOfWeek(.friday)]
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: days,
                                    daysOfTheMonth: nil, monthsOfTheYear: nil,
                                    weeksOfTheYear: nil, daysOfTheYear: nil,
                                    setPositions: nil, end: nil)
        case .weekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case .biweekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case .monthly:
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        }
    }
}
