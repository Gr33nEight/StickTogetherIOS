//
//  HabitListType.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/10/2026.
//

import SwiftUI

enum HabitListType: CaseIterable {
    case myHabits
    case friendsHabits
    
    var text: String {
        switch self {
        case .myHabits:
            return "My Habits"
        case .friendsHabits:
            return "Friends' Habits"
        }
    }
    
    var noHabitsText: String {
        switch self {
        case .myHabits:
            return "You don’t have any habits yet."
        case .friendsHabits:
            return "Your friends haven’t shared any preview habits yet."
        }
    }
}
