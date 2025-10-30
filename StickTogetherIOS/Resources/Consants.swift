//
//  Consants.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum Constants {
    static let sampleHabits: [Habit] = [
        Habit(icon: "🏃‍♂️", title: "Morning Run", streak: 7, totalCompleted: 21, buddy: "Alex", state: .both),
        Habit(icon: "📖", title: "Read 10 Pages", streak: 4, totalCompleted: 10, buddy: "Mia", state: .me),
        Habit(icon: "🧘‍♀️", title: "Meditation", streak: 12, totalCompleted: 35, buddy: "Noah", state: .buddy),
        Habit(icon: "🥦", title: "Eat Healthy", streak: 6, totalCompleted: 15, buddy: "Liam", state: .neither),
        Habit(icon: "🕒", title: "Sleep Before 11PM", streak: 9, totalCompleted: 28, buddy: "Emma", state: .both)
    ]
}
