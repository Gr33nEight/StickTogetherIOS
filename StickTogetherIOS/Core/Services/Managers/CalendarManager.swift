//
//  CalendarManager.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 11/11/2025.
//

import SwiftUI
import Combine
import EventKit

@MainActor
class CalendarManager {
    static let shared = CalendarManager()
    private init() {}

    private let eventStore = EKEventStore()
    private var appCalendar: EKCalendar? {
        eventStore.defaultCalendarForNewEvents
    }

    func requestAccess() async {
        do {
            try await eventStore.requestFullAccessToEvents()
        } catch {
            print("Something went wrong with requesting access to the calendar")
        }
    }

    func hasAccess() -> Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    func addHabitToCalendar(habit: Habit) throws {
        guard hasAccess() else {
            print("No calendar access")
            return
        }
        guard let calendar = appCalendar else {
            print("Default calendar unavailable")
            return
        }


        var cursor = habit.startDate.startOfDay
        let end = habit.endDate.startOfDay

        let cal = Calendar.current

        while cursor <= end {
            if habit.frequency.occurs(on: cursor, startDate: habit.startDate) {
                let event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
                event.title = habit.title

                let dayKey = Habit.dayKey(for: cursor)
                let hid = habit.id ?? UUID().uuidString
                let marker = "sticktogether;habitId=\(hid);day=\(dayKey)"
                if let existingNotes = event.notes, !existingNotes.isEmpty {
                    event.notes = existingNotes + "\n" + marker
                } else {
                    event.notes = marker
                }

                if let reminderTime = habit.reminderTime {
                    event.startDate = combine(date: cursor, with: reminderTime)
                    event.endDate = event.startDate.addingTimeInterval(30 * 60)
                    event.isAllDay = false
                } else {
                    event.startDate = cursor
                    event.endDate = cal.date(byAdding: .day, value: 1, to: cursor)!
                    event.isAllDay = true
                }

                try eventStore.save(event, span: .thisEvent)
            }

            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
    }
    
    func removeHabit(_ habit: Habit) {
        guard hasAccess() else { return }
        guard let calendar = appCalendar else {
            guard appCalendar != nil else { return }
            return
        }

        let hid = habit.id ?? ""
        let predicate = eventStore.predicateForEvents(withStart: habit.startDate.startOfDay, end: habit.endDate.startOfDay, calendars: [calendar])

        print(predicate)
        
        let events = eventStore.events(matching: predicate)
        
        print(events)
        
        let tag = "sticktogether;habitId=\(hid)"

        for event in events {
            if let notes = event.notes, notes.contains(tag) {
                try? eventStore.remove(event, span: .thisEvent)
            }
        }
    }

    private func combine(date: Date, with time: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: comps.second ?? 0, of: date.startOfDay) ?? date
    }
}
