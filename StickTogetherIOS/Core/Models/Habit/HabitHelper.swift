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

    func completionState(on date: Date, currentUserId: String, buddyId: String?) -> CompletionState {
        let key = Habit.dayKey(for: date)
        let users = completion[key] ?? []

        let meDid = users.contains(currentUserId)
        
        guard let buddyId else { return meDid ? .both : .neither }
        let buddyDid = users.contains(buddyId)
        
        print(currentUserId, " current user")
        print(buddyId, " buddy")
        
        print(meDid, " me did")
        print(buddyDid, " buddy did")

        switch (meDid, buddyDid) {
        case (true, true): return .both
        case (true, false): return .me
        case (false, true): return .buddy
        default: return .neither
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
        //TODO: $0.count == 2 zmieni się jak będzie można mieć więcej niż 1 buddiego!
        completion.values.filter { $0.count == 2 }.count
    }
    
    func streak(referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: referenceDate)
        while true {
            let key = Habit.dayKey(for: cursor, calendar: calendar)
            //TODO: list.count == 2 zmieni się jak będzie można mieć więcej niż 1 buddiego!
            if let list = completion[key], list.count == 2 {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
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
}
