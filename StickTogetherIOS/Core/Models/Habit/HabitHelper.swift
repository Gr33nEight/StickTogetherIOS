//
//  HabitHelper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import Foundation

extension Habit {
    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let y = components.year!, m = components.month!, d = components.day!
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
    
    func completionState(on date: Date, calendar: Calendar = .current) -> CompletionState {
        let key = Habit.dayKey(for: date, calendar: calendar)
        return completion[key] ?? .neither
    }
    
    func totalCompleted() -> Int {
        completion.values.filter { $0 == .both }.count
    }
    
    func streak(endingAt endDate: Date = Date(), calendar: Calendar = .current) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: endDate)
        
        guard cursor >= calendar.startOfDay(for: startDate) else { return 0 }
        
        while cursor >= calendar.startOfDay(for: startDate) {
            if frequency.occurs(on: cursor, startDate: startDate, calendar: calendar) {
                let state = completionState(on: cursor, calendar: calendar)
                if state != .both {
                    break
                } else {
                    streak += 1
                }
            }
            
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
    
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        frequency.occurs(on: date, startDate: startDate, calendar: calendar)
    }
}
