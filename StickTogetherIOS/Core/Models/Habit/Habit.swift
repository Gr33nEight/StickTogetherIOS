//
//  Habit.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import Foundation
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var title: String
    var icon: String
    var ownerId: String
    var buddyId: String? = nil
    var frequency: Frequency
    var startDate: Date
    var reminderTime: Date? = nil
    var alone: Bool = false
    var createdAt: Date = Date()

    var completion: [String: CompletionState] = [:]

    init(id: String? = nil,
         title: String,
         icon: String,
         ownerId: String,
         buddyId: String? = nil,
         frequency: Frequency,
         startDate: Date = Date(),
         reminderTime: Date? = nil,
         alone: Bool = false,
         createdAt: Date = Date(),
         completion: [String: CompletionState] = [:]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.ownerId = ownerId
        self.buddyId = buddyId
        self.frequency = frequency
        self.startDate = startDate
        self.reminderTime = reminderTime
        self.alone = alone
        self.createdAt = createdAt
        self.completion = completion
    }
}
