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

    private let center = UNUserNotificationCenter.current()
    private let categoryHabit = "HABIT_REMINDER"

    // MARK: - Setup

    func configure() {
        center.delegate = self

        let openAction = UNNotificationAction(
            identifier: "OPEN_ACTION",
            title: "Open",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: categoryHabit,
            actions: [openAction],
            intentIdentifiers: []
        )

        center.setNotificationCategories([category])
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Public API

    func scheduleNotifications(for habit: Habit, occurencesCaount: Int = 64) async {
        guard let habitId = habit.id else { return }
        guard let reminderTime = habit.reminderTime else { return }

        await cancelNotifications(for: habitId)

        let startsInFuture = habit.startDate > Date()

        switch habit.frequency.type {

        case .daily:
            let intervalDays = habit.frequency.intervalDays ?? 0

            if intervalDays <= 1 {
                if startsInFuture {
                    await scheduleOneShots(
                        habitId: habitId,
                        title: habit.title,
                        dates: [habit.startDate],
                        time: reminderTime
                    )
                } else {
                    scheduleRepeatingDaily(
                        habitId: habitId,
                        title: habit.title,
                        time: reminderTime
                    )
                }
            } else {
                let occurrences = habit.frequency.nextOccurrences(
                    from: habit.startDate,
                    after: Date(),
                    count: occurencesCaount
                )
                await scheduleOneShots(
                    habitId: habitId,
                    title: habit.title,
                    dates: occurrences,
                    time: reminderTime
                )
            }

        case .weekly:
            let intervalWeeks = habit.frequency.intervalWeeks ?? 0
            let days = habit.frequency.daysOfWeek ?? []

            if intervalWeeks <= 1 {
                if startsInFuture {
                    await scheduleOneShots(
                        habitId: habitId,
                        title: habit.title,
                        dates: [habit.startDate],
                        time: reminderTime
                    )
                } else {
                    if days.isEmpty {
                        let weekday = Calendar.current.component(.weekday, from: habit.startDate)
                        scheduleRepeatingWeekly(
                            habitId: habitId,
                            title: habit.title,
                            weekday: weekday,
                            time: reminderTime
                        )
                    } else {
                        for day in days {
                            scheduleRepeatingWeekly(
                                habitId: habitId,
                                title: habit.title,
                                weekday: day.rawValue,
                                time: reminderTime
                            )
                        }
                    }
                }
            } else {
                let occurrences = habit.frequency.nextOccurrences(
                    from: habit.startDate,
                    after: Date(),
                    count: occurencesCaount
                )
                await scheduleOneShots(
                    habitId: habitId,
                    title: habit.title,
                    dates: occurrences,
                    time: reminderTime
                )
            }

        case .monthly:
            let intervalMonths = habit.frequency.intervalMonths ?? 0

            if intervalMonths <= 1 {
                if startsInFuture {
                    await scheduleOneShots(
                        habitId: habitId,
                        title: habit.title,
                        dates: [habit.startDate],
                        time: reminderTime
                    )
                } else {
                    let day = Calendar.current.component(.day, from: habit.startDate)
                    scheduleRepeatingMonthly(
                        habitId: habitId,
                        title: habit.title,
                        day: day,
                        time: reminderTime
                    )
                }
            } else {
                let occurrences = habit.frequency.nextOccurrences(
                    from: habit.startDate,
                    after: Date(),
                    count: occurencesCaount
                )
                await scheduleOneShots(
                    habitId: habitId,
                    title: habit.title,
                    dates: occurrences,
                    time: reminderTime
                )
            }
        }
    }

    func rescheduleAll(habits: [Habit]) async {
        for habit in habits {
            await scheduleNotifications(for: habit)
        }
    }

    func cancelNotifications(for habitId: String) async {
        let ids = try? await pendingIdentifiersMatching(prefix: "habit_\(habitId)_")
        guard let ids, !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Repeating Schedulers

    private func scheduleRepeatingDaily(habitId: String, title: String, time: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        var dateComps = DateComponents()
        dateComps.hour = comps.hour
        dateComps.minute = comps.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
        scheduleRequest(
            id: notificationId(habitId: habitId, suffix: "daily"),
            title: title,
            trigger: trigger
        )
    }

    private func scheduleRepeatingWeekly(habitId: String, title: String, weekday: Int, time: Date) {
        var comps = DateComponents()
        comps.weekday = weekday

        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        scheduleRequest(
            id: notificationId(habitId: habitId, suffix: "weekly_\(weekday)"),
            title: title,
            trigger: trigger
        )
    }

    private func scheduleRepeatingMonthly(habitId: String, title: String, day: Int, time: Date) {
        var comps = DateComponents()
        comps.day = day

        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        scheduleRequest(
            id: notificationId(habitId: habitId, suffix: "monthly_\(day)"),
            title: title,
            trigger: trigger
        )
    }

    // MARK: - One-shots

    private func scheduleOneShots(
        habitId: String,
        title: String,
        dates: [Date],
        time: Date
    ) async {
        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)

        for (i, date) in dates.enumerated() {
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
            comps.hour = timeComps.hour
            comps.minute = timeComps.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            scheduleRequest(
                id: notificationId(habitId: habitId, suffix: "oneshot_\(i)"),
                title: title,
                trigger: trigger
            )
        }
    }

    // MARK: - Helpers

    private func notificationId(habitId: String, suffix: String) -> String {
        "habit_\(habitId)_\(suffix)"
    }

    private func scheduleRequest(
        id: String,
        title: String,
        body: String = "Time to complete your habit!",
        trigger: UNNotificationTrigger
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryHabit
        content.userInfo = ["habitId": id]

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("❌ Notification error:", error)
            }
        }
    }

    private func pendingIdentifiersMatching(prefix: String) async throws -> [String] {
        try await withCheckedThrowingContinuation { cont in
            center.getPendingNotificationRequests { requests in
                let ids = requests
                    .map(\.identifier)
                    .filter { $0.hasPrefix(prefix) }
                cont.resume(returning: ids)
            }
        }
    }
}

// MARK: - Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }

        if let habitId = response.notification.request.content.userInfo["habitId"] as? String {
            print("Tapped habit reminder:", habitId)
        }
    }
}
