//
//  nodeflowTests.swift
//  nodeflowTests
//
//  Created by נועם נאור on 05/04/2026.
//

import Testing
import SwiftData
import EventKit
@testable import nodeflow

// MARK: - TimeUtils

@Suite("TimeUtils")
struct TimeUtilsTests {
    @Test func seconds_only() {
        #expect(flowTimeString(45) == "00:45")
    }
    @Test func minutes_and_seconds() {
        #expect(flowTimeString(90) == "01:30")
    }
    @Test func exact_hour() {
        #expect(flowTimeString(3600) == "1:00:00")
    }
    @Test func hours_minutes_seconds() {
        #expect(flowTimeString(3723) == "1:02:03")
    }
    @Test func zero() {
        #expect(flowTimeString(0) == "00:00")
    }
}

// MARK: - Flow model

@Suite("Flow model")
struct FlowModelTests {
    @Test func default_values() {
        let flow = Flow(title: "Morning Routine")
        #expect(flow.title == "Morning Routine")
        #expect(flow.notes == "")
        #expect(flow.isRecurring == false)
        #expect(flow.calendarProvider == .none)
        #expect(flow.nodes.isEmpty)
        #expect(!flow.deepLinkID.isEmpty)
    }

    @Test func deepLinkID_is_unique() {
        let a = Flow(title: "A")
        let b = Flow(title: "B")
        #expect(a.deepLinkID != b.deepLinkID)
    }

    @Test func custom_values_stored() {
        let flow = Flow(
            title: "Evening Wind Down",
            emoji: "🌙",
            notes: "Relax before bed",
            isRecurring: true,
            recurrenceFrequency: .daily,
            calendarProvider: .apple
        )
        #expect(flow.emoji == "🌙")
        #expect(flow.notes == "Relax before bed")
        #expect(flow.isRecurring == true)
        #expect(flow.recurrenceFrequency == .daily)
        #expect(flow.calendarProvider == .apple)
    }
}

// MARK: - FlowNode model

@Suite("FlowNode model")
struct FlowNodeTests {
    @Test func default_values() {
        let node = FlowNode(title: "Brush Teeth")
        #expect(node.title == "Brush Teeth")
        #expect(node.notes == "")
        #expect(node.order == 0)
        #expect(node.durationMinutes == nil)
        #expect(node.emoji == nil)
    }

    @Test func custom_values_stored() {
        let node = FlowNode(title: "Meditate", emoji: "🧘", notes: "Focus on breathing", durationMinutes: 10, order: 2)
        #expect(node.emoji == "🧘")
        #expect(node.notes == "Focus on breathing")
        #expect(node.durationMinutes == 10)
        #expect(node.order == 2)
    }
}

// MARK: - RecurrenceFrequency rruleString

@Suite("RecurrenceFrequency rruleString")
struct RecurrenceFrequencyRRuleTests {
    @Test func daily() {
        #expect(RecurrenceFrequency.daily.rruleString == "RRULE:FREQ=DAILY")
    }
    @Test func weekly() {
        #expect(RecurrenceFrequency.weekly.rruleString == "RRULE:FREQ=WEEKLY")
    }
    @Test func biweekly() {
        #expect(RecurrenceFrequency.biweekly.rruleString == "RRULE:FREQ=WEEKLY;INTERVAL=2")
    }
    @Test func monthly() {
        #expect(RecurrenceFrequency.monthly.rruleString == "RRULE:FREQ=MONTHLY")
    }
    @Test func weekdays_includes_byday() {
        #expect(RecurrenceFrequency.weekdays.rruleString.contains("BYDAY=MO,TU,WE,TH,FR"))
    }
}

// MARK: - RecurrenceFrequency EKRecurrenceRule

@Suite("RecurrenceFrequency ekRecurrenceRule")
struct RecurrenceFrequencyEKTests {
    @Test func daily_rule() {
        let rule = RecurrenceFrequency.daily.ekRecurrenceRule
        #expect(rule.frequency == .daily)
        #expect(rule.interval == 1)
    }
    @Test func weekly_rule() {
        let rule = RecurrenceFrequency.weekly.ekRecurrenceRule
        #expect(rule.frequency == .weekly)
        #expect(rule.interval == 1)
    }
    @Test func biweekly_rule() {
        let rule = RecurrenceFrequency.biweekly.ekRecurrenceRule
        #expect(rule.frequency == .weekly)
        #expect(rule.interval == 2)
    }
    @Test func monthly_rule() {
        let rule = RecurrenceFrequency.monthly.ekRecurrenceRule
        #expect(rule.frequency == .monthly)
        #expect(rule.interval == 1)
    }
    @Test func weekdays_rule_has_five_days() {
        let rule = RecurrenceFrequency.weekdays.ekRecurrenceRule
        #expect(rule.frequency == .weekly)
        #expect(rule.daysOfTheWeek?.count == 5)
    }
}

// MARK: - CalendarProvider

@Suite("CalendarProvider")
struct CalendarProviderTests {
    @Test func raw_values() {
        #expect(CalendarProvider.none.rawValue == "None")
        #expect(CalendarProvider.apple.rawValue == "Apple Calendar")
        #expect(CalendarProvider.google.rawValue == "Google Calendar")
    }
    @Test func all_cases_count() {
        #expect(CalendarProvider.allCases.count == 3)
    }
}

// MARK: - SwiftData container

@Suite("SwiftData container")
struct DataServiceTests {
    @Test func container_creates_successfully() throws {
        #expect(throws: Never.self) {
            _ = try DataService.makeContainer()
        }
    }

    @Test func can_insert_and_fetch_flow() throws {
        let container = try ModelContainer(
            for: Flow.self, FlowNode.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let flow = Flow(title: "Test Flow")
        context.insert(flow)
        try context.save()

        let flows = try context.fetch(FetchDescriptor<Flow>())
        #expect(flows.count == 1)
        #expect(flows.first?.title == "Test Flow")
    }

    @Test func cascade_delete_removes_nodes() throws {
        let container = try ModelContainer(
            for: Flow.self, FlowNode.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let node = FlowNode(title: "Step 1")
        let flow = Flow(title: "My Flow", nodes: [node])
        context.insert(flow)
        try context.save()

        context.delete(flow)
        try context.save()

        let nodes = try context.fetch(FetchDescriptor<FlowNode>())
        #expect(nodes.isEmpty)
    }
}

