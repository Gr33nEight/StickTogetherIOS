//
//  Habit.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct Habit: Identifiable {
    let id: UUID = UUID()
    let icon: String
    let title: String
    let streak: Int
    let totalCompleted: Int
//    let frequency: 
//    let buddyId: String
    let buddy: String
    let state: CompletionState
}
