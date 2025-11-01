//
//  Consants.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension Habit {
    init(icon: String, title: String, streak: Int, totalCompleted: Int, buddy: String?, state: CompletionState) {
        self.title = title
        self.icon = icon
        self.ownerId = "demo_user"
        self.buddyId = buddy
        self.alone = buddy == nil
        self.frequency = Frequency(type: .daily, intervalDays: 0)
        self.startDate = Date()
        self.reminderTime = nil
        self.streak = streak
        self.totalCompleted = totalCompleted
        self.state = state
        self.createdAt = Date()
    }
}

enum Constants {
    static let sampleHabits: [Habit] = [
        Habit(icon: "🏃‍♂️", title: "Morning Run", streak: 7, totalCompleted: 21, buddy: "Alex", state: .both),
        Habit(icon: "📖", title: "Read 10 Pages", streak: 4, totalCompleted: 10, buddy: "Mia", state: .me),
        Habit(icon: "🧘‍♀️", title: "Meditation", streak: 12, totalCompleted: 35, buddy: "Noah", state: .buddy),
        Habit(icon: "🥦", title: "Eat Healthy", streak: 6, totalCompleted: 15, buddy: "Liam", state: .neither),
        Habit(icon: "🕒", title: "Sleep Before 11PM", streak: 9, totalCompleted: 28, buddy: "Emma", state: .both)
    ]
}
