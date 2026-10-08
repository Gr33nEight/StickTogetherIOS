//
//  HabitEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

struct HabitEntry: Identifiable {
    var id: String?
    var habitId: String
    var userId: String
    var date: Date
    var status: HabitEntryStatus
}
