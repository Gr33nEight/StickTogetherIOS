//
//  Habit.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var title: String
    var icon: String
    var ownerId: String
    var buddyId: String? = nil
    var frequency: Frequency //TODO: For now later one should be dedicated model
    var startDate: Date
    var reminderTime: String? = nil
    var alone: Bool = false
    var createdAt: Date = Date()
    var meta: [String: String]? = nil // not sure about it
    
    let streak: Int
    let totalCompleted: Int
    let state: CompletionState
}
