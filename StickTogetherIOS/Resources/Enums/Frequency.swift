//
//  Frequency.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum Weekday: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortened: String {
        switch self {
        case .monday:
            return "Mon"
        case .tuesday:
            return "Tue"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thu"
        case .friday:
            return "Fri"
        case .saturday:
            return "Sat"
        case .sunday:
            return "Sun"
        }
    }
}

enum FrequencyType: String, Codable, CaseIterable {
    case daily, weekly, monthly
    
    var limit: Int {
        switch self {
        case .daily:
            return 365
        case .weekly:
            return 52
        case .monthly:
            return 12
        }
    }
    
    var value: String {
        switch self {
        case .daily:
            "days"
        case .weekly:
            "weeks"
        case .monthly:
            "months"
        }
    }
}

struct Frequency: Codable, Equatable {
    var type: FrequencyType
    var intervalDays: Int?
    
    var intervalWeeks: Int?
    var daysOfWeek: [Weekday]?
    
    var intervalMonths: Int?
    
    static func daily(everyDays: Int = 0) -> Frequency {
        Frequency(type: .daily, intervalDays: max(0, min(everyDays, FrequencyType.daily.limit)), intervalWeeks: nil, daysOfWeek: nil, intervalMonths: nil)
    }
    
    static func weekly(everyWeeks: Int = 0, daysOfWeek: [Weekday]? = nil) -> Frequency {
        Frequency(type: .weekly, intervalDays: nil, intervalWeeks: max(0, min(everyWeeks, FrequencyType.weekly.limit)), daysOfWeek: daysOfWeek, intervalMonths: nil)
    }
    
    static func monthly(everyMonths: Int = 0) -> Frequency {
        Frequency(type: .monthly, intervalDays: nil, intervalWeeks: nil, daysOfWeek: nil, intervalMonths: max(0, min(everyMonths, FrequencyType.monthly.limit)))
    }
}

extension Frequency {
    func occurs(on date: Date, startDate: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)
        
        if day < start { return false }
        
        switch type {
        case .daily:
            let interval = intervalDays ?? 0
            let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            if interval == 0 { return true }
            return diff % (interval) == 0
        case .weekly:
            let intervalW = intervalWeeks ?? 0
            let daysDiff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            let weeksDiff = daysDiff / 7
            if (intervalW == 0) {
                return dayMatchesWeekly(day: day, calendar: calendar)
            } else {
                if weeksDiff % (intervalW) != 0 { return false }
                return dayMatchesWeekly(day: day, calendar: calendar)
            }
        case .monthly:
            let intervalM = intervalMonths ?? 0
            let comps = calendar.dateComponents([.month], from: start, to: day)
            let monthsDiff = comps.month ?? 0
            if monthsDiff % intervalM != 0 { return false }
            
            let startDOM = calendar.component(.day, from: start)
            let dayDOM = calendar.component(.day, from: day)
            if dayDOM == startDOM { return true }
            
            if let range = calendar.range(of: .day, in: .month, for: day){
                if startDOM > range.count && dayDOM == range.count {
                    return true
                }
            }
            return false
        }
    }
    
    private func dayMatchesWeekly(day: Date, calendar: Calendar) -> Bool {
        guard let days = daysOfWeek, !days.isEmpty else {
            return true
        }
        let weekday = calendar.component(.weekday, from: day)
        return days.contains { $0.rawValue == weekday }
    }
}

extension Frequency {
    func nextOccurrences(from start: Date, after fromDate: Date = Date(), count: Int = 10, calendar: Calendar = .current) -> [Date] {
        var results: [Date] = []
        var cursor = max(calendar.startOfDay(for: fromDate), calendar.startOfDay(for: start))
        let safetyLimit = 3650
        var tries = 0

        while results.count < count && tries < safetyLimit {
            tries += 1
            if occurs(on: cursor, startDate: start, calendar: calendar) {
                if cursor >= calendar.startOfDay(for: start) && cursor >= calendar.startOfDay(for: fromDate) {
                    results.append(cursor)
                }
            }
            
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return results
    }
}
