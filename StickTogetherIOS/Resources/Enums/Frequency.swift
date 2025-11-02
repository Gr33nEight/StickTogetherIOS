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
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

enum FrequencyType: String, Codable, CaseIterable {
    case daily, weekly, monthly

    var limit: Int {
        switch self {
        case .daily: return 365
        case .weekly: return 52
        case .monthly: return 12
        }
    }

    var value: String {
        switch self {
        case .daily: return "days"
        case .weekly: return "weeks"
        case .monthly: return "months"
        }
    }
}

struct Frequency: Codable, Equatable {
    var type: FrequencyType
    // semantics: interval = 1 means every 1 (every day / every week / every month)
    var intervalDays: Int?      // used when type == .daily
    var intervalWeeks: Int?     // used when type == .weekly
    var daysOfWeek: [Weekday]?  // used when type == .weekly
    var intervalMonths: Int?    // used when type == .monthly

    // MARK: - factories (default interval = 1)
    static func daily(everyDays: Int = 1) -> Frequency {
        let safe = max(1, min(everyDays, FrequencyType.daily.limit))
        return Frequency(type: .daily, intervalDays: safe, intervalWeeks: nil, daysOfWeek: nil, intervalMonths: nil)
    }

    static func weekly(everyWeeks: Int = 1, daysOfWeek: [Weekday]? = nil) -> Frequency {
        let safe = max(1, min(everyWeeks, FrequencyType.weekly.limit))
        return Frequency(type: .weekly, intervalDays: nil, intervalWeeks: safe, daysOfWeek: daysOfWeek, intervalMonths: nil)
    }

    static func monthly(everyMonths: Int = 1) -> Frequency {
        let safe = max(1, min(everyMonths, FrequencyType.monthly.limit))
        return Frequency(type: .monthly, intervalDays: nil, intervalWeeks: nil, daysOfWeek: nil, intervalMonths: safe)
    }
}

extension Frequency {
    func occurs(on date: Date, startDate: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)

        if day < start { return false }

        switch type {
        case .daily:
            let interval = max(1, (intervalDays ?? 1))
            let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            return diff % interval == 0

        case .weekly:
            let intervalW = max(1, (intervalWeeks ?? 1))
            let daysDiff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            let weeksDiff = daysDiff / 7
            if weeksDiff % intervalW != 0 { return false }
            return dayMatchesWeekly(day: day, calendar: calendar)

        case .monthly:
            let intervalM = max(1, (intervalMonths ?? 1))
            let comps = calendar.dateComponents([.month], from: start, to: day)
            let monthsDiff = comps.month ?? 0
            if monthsDiff % intervalM != 0 { return false }

            let startDOM = calendar.component(.day, from: start)
            let dayDOM = calendar.component(.day, from: day)
            if dayDOM == startDOM { return true }

            if let range = calendar.range(of: .day, in: .month, for: day) {
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
        let systemWeekday = calendar.component(.weekday, from: day)
        let ourWeekday = ((systemWeekday + 5) % 7) + 1
        return days.contains { $0.rawValue == ourWeekday }
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

extension Frequency {
    var readableDescription: String {
        switch type {
        case .daily:
            let n = intervalDays ?? 1
            return n == 1
                ? "Every day"
                : "Every \(ordinal(n)) day"

        case .weekly:
            let n = intervalWeeks ?? 1
            let days = daysOfWeek ?? []
            if !days.isEmpty {
                // sort to consistent order
                let sorted = days.sorted { $0.rawValue < $1.rawValue }
                let names = sorted.map { $0.shortened }
                // detect weekday/weekend patterns
                if names == ["Mon", "Tue", "Wed", "Thu", "Fri"] {
                    return "Every weekday"
                } else if names == ["Sat", "Sun"] {
                    return "Every weekend"
                } else {
                    return "Every \(n == 1 ? "" : "\(ordinal(n)) ")week on \(names.joined(separator: ", "))"
                }
            } else {
                return n == 1 ? "Every week" : "Every \(ordinal(n)) week"
            }

        case .monthly:
            let n = intervalMonths ?? 1
            return n == 1
                ? "Every month"
                : "Every \(ordinal(n)) month"
        }
    }

    /// Returns 1st, 2nd, 3rd, 4th, 11th, etc.
    private func ordinal(_ number: Int) -> String {
        let suffix: String
        let tens = number % 100
        if tens >= 11 && tens <= 13 {
            suffix = "th"
        } else {
            switch number % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(number)\(suffix)"
    }
}
