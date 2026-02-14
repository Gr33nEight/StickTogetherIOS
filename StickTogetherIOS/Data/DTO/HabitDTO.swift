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
    var title: String
    var icon: String
    var ownerId: String
    var buddyId: String = ""
    var frequency: Frequency
    var startDate: Date
    var endDate: Date
    var reminderTime: Date? = nil
    var createdAt: Date = Date()
    var completion: [String: [String]]
    var type: HabitType = .alone
}
