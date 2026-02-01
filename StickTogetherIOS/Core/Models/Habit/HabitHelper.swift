//
//  HabitHelper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import Foundation

extension Habit {
    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        guard let d = calendar.date(from: comps) else { return ISO8601DateFormatter().string(from: date) }
        let fmt = DateFormatter()
        fmt.timeZone = calendar.timeZone
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: d)
    }

    func completionState(
        on date: Date,
        currentUserId: String
    ) -> CompletionState {

        let key = Habit.dayKey(for: date)
        let users = completion[key] ?? []

        switch type {
        case .alone:
            return aloneState(users: users, currentUserId: currentUserId)

        case .coop:
            return coopState(
                users: users,
                currentUserId: currentUserId,
                ownerId: ownerId,
                buddyId: buddyId
            )

        case .preview:
            // preview = alone for owner, coop for buddy
            if currentUserId == ownerId {
                return aloneState(users: users, currentUserId: currentUserId)
            } else {
                return coopState(
                    users: users,
                    currentUserId: currentUserId,
                    ownerId: ownerId,
                    buddyId: buddyId
                )
            }
        }
    }
    
    private func aloneState(
        users: [String],
        currentUserId: String
    ) -> CompletionState {
        users.contains(currentUserId) ? .both : .neither
    }
    
    private func coopState(
        users: [String],
        currentUserId: String,
        ownerId: String,
        buddyId: String
    ) -> CompletionState {

        guard !buddyId.isEmpty else {
            return users.contains(currentUserId) ? .both : .neither
        }

        let otherUserId = (currentUserId == ownerId) ? buddyId : ownerId

        let meDid = users.contains(currentUserId)
        let otherDid = users.contains(otherUserId)

        switch (meDid, otherDid) {
        case (true, true): return .both
        case (true, false): return .me
        case (false, true): return .buddy
        case (false, false): return .neither
        }
    }

    mutating func markCompleted(by userId: String, on date: Date) {
        let key = Habit.dayKey(for: date)
        var list = completion[key] ?? []
        if !list.contains(userId) {
            list.append(userId)
            completion[key] = list
        }
    }

    mutating func unmarkCompleted(by userId: String, on date: Date) {
        let key = Habit.dayKey(for: date)
        guard var list = completion[key] else { return }
        list.removeAll { $0 == userId }
        if list.isEmpty {
            completion.removeValue(forKey: key)
        } else {
            completion[key] = list
        }
    }

    func totalCompleted() -> Int {
        completion.values.filter { $0.count == numberOfParticipants() }.count
    }
    
    func streak(
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        var streak = 0

        // start at today (or reference)
        var cursor = calendar.startOfDay(for: referenceDate)

        // if today is NOT an occurrence day → move to last occurrence
        if !frequency.occurs(on: cursor, startDate: startDate) {
            guard let prev = previousOccurrence(before: cursor, calendar: calendar) else {
                return 0
            }
            cursor = prev
        }

        while true {
            let key = Habit.dayKey(for: cursor, calendar: calendar)
            let completed = completion[key]?.count == numberOfParticipants()

            guard completed else { break }

            streak += 1

            guard let prev = previousOccurrence(before: cursor, calendar: calendar) else {
                break
            }

            cursor = prev
        }

        return streak
    }
    
    func isMarkedAsDone(by userId: String, on date: Date) -> Bool {
        let key = Habit.dayKey(for: date)
        return completion[key]?.contains(userId) == true
    }
    
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        frequency.occurs(on: date, startDate: startDate, calendar: calendar)
    }
    
    //TODO: Temporary
    func numberOfParticipants() -> Int {
        return type == .coop ? (buddyId.isEmpty ? 1 : 2) : 1
    }
    
    func completionCount(forDayKey key: String) -> Int {
        completion[key]?.count ?? 0
    }
    
    func userDidComplete(_ userId: String, forDayKey key: String) -> Bool {
        completion[key]?.contains(userId) ?? false
    }
    
    func sortPriority(date: Date, currentUserId: String) -> Int {
        let solo = buddyId.isEmpty
        switch completionState(on: date, currentUserId: currentUserId) {
        case .both: return solo ? 0 : 1
        case .me: return 2
        case .buddy: return 3
        case .neither: return 4
        }
    }
    
    func datesWhenHabitOccurs() -> [Date] {
        var result: [Date] = []

        let calendar = Calendar.current

        let start = Date.now.firstWeekDayBeforeStart
        let end = calendar.date(
            byAdding: .day,
            value: Date.now.numberOfDaysInMonth,
            to: Date.now.startOfMonth
        )!

        var day = start

        while day < end {
            if frequency.occurs(on: day, startDate: startDate) {
                result.append(day)
            }
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }

        return result
    }
    
    func previousOccurrence(
        before date: Date,
        calendar: Calendar = .current
    ) -> Date? {
        var cursor = calendar.startOfDay(for: date)

        while true {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return nil
            }
            cursor = prev

            if frequency.occurs(on: cursor, startDate: startDate) {
                return cursor
            }
            
            if cursor < startDate {
                return nil
            }
        }
    }
}
