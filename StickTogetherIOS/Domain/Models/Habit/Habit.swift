//
//  Habit.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import Foundation

struct Habit: Identifiable {
    var id: String? = nil
    var title: String
    var icon: String
    var ownerId: String
    var acceptedBuddyIds: [String]
    var invitedBuddyIds: [String]
    var frequency: Frequency
    var startDate: Date
    var endDate: Date
    var reminderTime: Date? = nil
    var createdAt: Date = Date()
    var type: HabitType = .alone
    var longestStreak: Int = 0
    var currentStreak: Int = 0
    var allCompleted: Int = 0
}

//extension Habit {
//    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
//        let comps = calendar.dateComponents([.year, .month, .day], from: date)
//        guard let d = calendar.date(from: comps) else { return ISO8601DateFormatter().string(from: date) }
//        let fmt = DateFormatter()
//        fmt.timeZone = calendar.timeZone
//        fmt.dateFormat = "yyyy-MM-dd"
//        return fmt.string(from: d)
//    }
//    
//    private func aloneState(
//        users: [String],
//        currentUserId: String
//    ) -> CompletionState {
//        users.contains(currentUserId) ? .all : .neither
//    }
//    
//    private func coopState(
//        users: [String],
//        currentUserId: String,
//        ownerId: String,
//        buddyId: String
//    ) -> CompletionState {
//
//        guard !buddyId.isEmpty else {
//            return users.contains(currentUserId) ? .all : .neither
//        }
//
//        let otherUserId = (currentUserId == ownerId) ? buddyId : ownerId
//
//        let meDid = users.contains(currentUserId)
//        let otherDid = users.contains(otherUserId)
//
//        switch (meDid, otherDid) {
//        case (true, true): return .all
//        case (true, false): return .me
//        case (false, true): return .buddy
//        case (false, false): return .neither
//        }
//    }
//
//    mutating func markCompleted(by userId: String, on date: Date) {
//        let key = Habit.dayKey(for: date)
//        var list = completion[key] ?? []
//        if !list.contains(userId) {
//            list.append(userId)
//            completion[key] = list
//        }
//    }
//
//    mutating func unmarkCompleted(by userId: String, on date: Date) {
//        let key = Habit.dayKey(for: date)
//        guard var list = completion[key] else { return }
//        list.removeAll { $0 == userId }
//        if list.isEmpty {
//            completion.removeValue(forKey: key)
//        } else {
//            completion[key] = list
//        }
//    }
//
//    func totalCompleted() -> Int {
//        //TODO: $0.count == 2 zmieni się jak będzie można mieć więcej niż 1 buddiego!
//        completion.values.filter { $0.count == 2 }.count
//    }
//    
//    func streak(referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
//        var streak = 0
//        var cursor = calendar.startOfDay(for: referenceDate)
//        while true {
//            let key = Habit.dayKey(for: cursor, calendar: calendar)
//            //TODO: list.count == 2 zmieni się jak będzie można mieć więcej niż 1 buddiego!
//            if let list = completion[key], list.count == 2 {
//                streak += 1
//                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
//                cursor = prev
//            } else {
//                break
//            }
//        }
//        return streak
//    }
//    
//    func isMarkedAsDone(by userId: String, on date: Date) -> Bool {
//        let key = Habit.dayKey(for: date)
//        return completion[key]?.contains(userId) == true
//    }
//    
//    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
//        frequency.occurs(on: date, startDate: startDate, calendar: calendar)
//    }
//    
//    //TODO: Temporary
//    func numberOfParticipants() -> Int {
//        return buddyIds.count + 1
//    }
//    
//    func completionCount(forDayKey key: String) -> Int {
//        completion[key]?.count ?? 0
//    }
//    
//    func userDidComplete(_ userId: String, forDayKey key: String) -> Bool {
//        completion[key]?.contains(userId) ?? false
//    }
//    
//    func sortPriority(date: Date, currentUserId: String) -> Int {
////        let solo = buddyId.isEmpty
////        switch completionState(on: date, currentUserId: currentUserId) {
////        case .all: return solo ? 0 : 1
////        case .me: return 2
////        case .buddy: return 3
////        case .neither: return 4
////        }
//        1
//    }
//}
