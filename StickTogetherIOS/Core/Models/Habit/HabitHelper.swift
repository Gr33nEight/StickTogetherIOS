//
//  HabitHelper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import Foundation

extension Habit {
    // MARK: - dayKey helpers
    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let y = components.year!, m = components.month!, d = components.day!
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func completionState(on date: Date, calendar: Calendar = .current) -> CompletionState {
        let key = Habit.dayKey(for: date, calendar: calendar)
        return completion[key] ?? .neither
    }

    // Set completion for a day (mutating local model; write to firestore separately)
    mutating func setCompletion(_ state: CompletionState, on date: Date, calendar: Calendar = .current) {
        let key = Habit.dayKey(for: date, calendar: calendar)
        completion[key] = state
    }

    // Remove completion (e.g. undo)
    mutating func removeCompletion(on date: Date, calendar: Calendar = .current) {
        let key = Habit.dayKey(for: date, calendar: calendar)
        completion.removeValue(forKey: key)
    }

    // Count total completions (count days where user or buddy completed depending on what you want)
    func totalCompleted() -> Int {
        // define what counts as a completion — here we count any day where state != .neither
        completion.values.filter { $0 != .neither }.count
    }

    // Compute streak ending at `endDate` (inclusive). A streak is number of consecutive occurrence-days (respecting frequency)
    func streak(endingAt endDate: Date = Date(), calendar: Calendar = .current) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: endDate)

        // If endDate is earlier than startDate, streak is 0
        guard cursor >= calendar.startOfDay(for: startDate) else { return 0 }

        // walk backwards while the habit occurs on the cursor date and completion != .neither
        while cursor >= calendar.startOfDay(for: startDate) {
            // check if habit is scheduled that day
            if frequency.occurs(on: cursor, startDate: startDate, calendar: calendar) {
                let state = completionState(on: cursor, calendar: calendar)
                if state == .neither {
                    break
                } else {
                    streak += 1
                }
            }
            // move one day back
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    // Convenience: check if habit is scheduled on date (respects frequency + startDate)
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        frequency.occurs(on: date, startDate: startDate, calendar: calendar)
    }

    // Whether user can mark this date (for now: only allow today). You can change rules later.
    func canMark(date: Date, calendar: Calendar = .current) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        // disallow marking future or past (only today allowed) — change if you want +/- window
        return target == today
    }
}
