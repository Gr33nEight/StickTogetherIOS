//
//  HabitInput.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

struct CreateHabitInput {
    let title: String
    let icon: String
    let frequency: Frequency
    let startDate: Date
    let endDate: Date
    let reminderTime: Date?
    let type: HabitType
    let buddyId: String?
}
