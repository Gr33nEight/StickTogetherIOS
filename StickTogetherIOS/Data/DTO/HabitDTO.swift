//
//  HabitDTO.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import FirebaseFirestore

struct HabitDTO: Codable, Equatable {
    @DocumentID var id: String? = nil
    var title: String = ""
    var icon: String = ""
    var ownerId: String = ""
    
    var acceptedBuddyIds: [String] = []
    var invitedBuddyIds: [String] = []
    
    var frequency: Frequency = .daily()
    var startDate: Date = Date()
    var endDate: Date = Date()
    var reminderTime: Date? = nil
    var createdAt: Date = Date()
    var type: HabitType = .alone
    var longestStreak: Int = 0
    var currentStreak: Int = 0
    var allCompleted: Int = 0
}
