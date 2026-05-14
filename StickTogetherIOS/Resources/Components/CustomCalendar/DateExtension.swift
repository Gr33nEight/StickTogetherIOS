//
//  DateExtension.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import Foundation

extension Date {
    static var firstDayOfWeek = Calendar.current.firstWeekday
    
    static var capitalizedFirstLettersOfWeekdays: [String] {
        let calendar = Calendar.current
        // Adjusted for the different weekday starts
        var weekdays = calendar.shortWeekdaySymbols
        if firstDayOfWeek > 1 {
            for _ in 1..<firstDayOfWeek {
                if let first = weekdays.first {
                    weekdays.append(first)
                    weekdays.removeFirst()
                }
            }
        }
        return weekdays.map { $0.capitalized }
    }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    var firstWeekDayBeforeStart: Date {
       let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
       var numberFromPreviousMonth = startOfMonthWeekday - Self.firstDayOfWeek
       if numberFromPreviousMonth < 0 {
           numberFromPreviousMonth += 7 // Adjust to a 0-6 range if negative
       }
       return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth)!
    }
    
    var calendarDisplayDays: [Date] {
       var days: [Date] = []
       // Start with days from the previous month to fill the grid
       let firstDisplayDay = firstWeekDayBeforeStart
       var day = firstDisplayDay
       while day < startOfMonth {
           days.append(day)
           day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
       }
       // Add days of the current month
       for dayOffset in 0..<numberOfDaysInMonth {
           if let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
               days.append(newDay)
           }
       }
       return days
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var hourInt: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var minuteInt: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: self)
    }
    
    var formattedDateHourCombined: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
}

extension Date {
    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
}
