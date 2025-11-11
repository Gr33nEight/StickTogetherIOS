//
//  NotificationManager.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 11/11/2025.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private override init() { super.init() }
    
    let center = UNUserNotificationCenter.current()
    let categoryHabit = "HABIT_REMINDER"
    
    func configure() {
        center.delegate = self
        
        let openAction = UNNotificationAction(identifier: "OPEN_ACTION", title: "Open", options: [.foreground])
        let category = UNNotificationCategory(identifier: categoryHabit, actions: [openAction], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotifications(for habit: Habit, occurencesCaount: Int = 64) async {
        guard let habitId = habit.id else { return }
        guard let reminderTime = habit.reminderTime else { return }
        
        await cancelNotifications(for: habitId)
        
        switch habit.frequency.type {
        case .daily:
            let intervalDays = habit.frequency.intervalDays ?? 0
            if intervalDays <= 1 {
                scheduleRepeatingDaily(habitId: habitId, title: habit.title, time: reminderTime)
            } else {
                let occurences = habit.frequency.nextOccurrences(from: habit.startDate, after: Date(), count: occurencesCaount)
                await scheduleOneShots(habitId: habitId, title: habit.title, dates: occurences, time: reminderTime)
            }
        case .weekly:
            let intervalWeeks = habit.frequency.intervalWeeks ?? 0
            let days = habit.frequency.daysOfWeek ?? []
            if intervalWeeks <= 1 {
                if days.isEmpty {
                    let weekday = Calendar.current.component(.weekday, from: habit.startDate)
                    scheduleRepeatingWeekly(habitId: habitId, title: habit.title, weekday: weekday, time: reminderTime)
                }else{
                    for day in days {
                        scheduleRepeatingWeekly(habitId: habitId, title: habit.title, weekday: day.rawValue, time: reminderTime)
                    }
                }
            }else{
                let occurences = habit.frequency.nextOccurrences(from: habit.startDate, after: Date(), count: occurencesCaount)
                await scheduleOneShots(habitId: habitId, title: habit.title, dates: occurences, time: reminderTime)
            }
        case .monthly:
            let intervalMonths = habit.frequency.intervalMonths ?? 0
            if intervalMonths <= 1 {
                let day = Calendar.current.component(.day, from: habit.startDate)
                scheduleRepeatingMonthly(habitId: habitId, title: habit.title, day: day, time: reminderTime)
            } else {
                let occurances = habit.frequency.nextOccurrences(from: habit.startDate, after: Date(), count: occurencesCaount)
                await scheduleOneShots(habitId: habitId, title: habit.title, dates: occurances, time: reminderTime)
            }
        }
    }
    
    func cancelNotifications(for habitId: String) async {
        let ids = try? await pendingIdentifiersMatching(prefix: "habit_\(habitId)_")
        guard let ids = ids, !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    func rescheduleAll(habits: [Habit]) async {
        for habit in habits {
            await scheduleNotifications(for: habit)
        }
    }
    
    private func scheduleRepeatingDaily(habitId: String, title: String, time: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        var dateComps = DateComponents()
        dateComps.hour = comps.hour
        dateComps.minute = comps.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
        let id = notificationId(habitId: habitId, suffix: "daily")
        scheduleRequest(id: id, title: title, trigger: trigger, userInfo: ["habitId" : habitId])
    }
    
    private func scheduleRepeatingWeekly(habitId: String, title: String, weekday: Int, time: Date) {
        var comps = DateComponents()
        comps.weekday = weekday
        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let id = notificationId(habitId: habitId, suffix: "weekly_\(weekday)")
        scheduleRequest(id: id, title: title, trigger: trigger, userInfo: ["habitId" : habitId])
    }
    
    private func scheduleRepeatingMonthly(habitId: String, title: String, day: Int, time: Date) {
        var comps = DateComponents()
        comps.day = day
        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let id = notificationId(habitId: habitId, suffix: "monthly_\(day)")
        scheduleRequest(id: id, title: title, trigger: trigger, userInfo: ["habitId" : habitId])
    }
    
    private func notificationId(habitId: String, suffix: String) -> String {
        "habit_\(habitId)_\(suffix)"
    }
    
    private func scheduleRequest(id: String, title: String, body: String = "Time to complete your habit!", trigger: UNNotificationTrigger, userInfo: [AnyHashable : Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryHabit
        content.userInfo = userInfo
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { err in
            if let err = err {
                print("Error scheduling notification: \(err)")
            }
        }
    }
    
    private func scheduleOneShots(habitId: String, title: String, dates: [Date], time: Date) async {
        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
        for (i, date) in dates.enumerated() {
            var comp = Calendar.current.dateComponents([.year, .month, .day], from: date)
            comp.hour = timeComps.hour
            comp.minute = timeComps.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
            let id = notificationId(habitId: habitId, suffix: "oneshot_\(i)")
            scheduleRequest(id: id, title: title, trigger: trigger, userInfo: ["habitId" : habitId])
        }
    }
    
    private func pendingIdentifiersMatching(prefix: String) async throws -> [String] {
        try await withCheckedThrowingContinuation { cont in
            center.getPendingNotificationRequests { requests in
                let ids = requests.map({ $0.identifier }).filter({ $0.hasPrefix(prefix) })
                cont.resume(returning: ids)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler:
                                        @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound])
        }

    // handle user tapping on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        let userInfo = response.notification.request.content.userInfo
        if let habitId = userInfo["habitId"] as? String {
            // TODO: open app to habit detail via deep link service or whatever
            print("Tapped habit reminder: \(habitId)")
        }
    }
}
