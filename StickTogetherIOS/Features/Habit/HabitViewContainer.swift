//
//  HabitViewContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/12/2025.
//

import Foundation

struct HabitViewContainer: Codable {
    let habitId: String?
    let selectedDate: Date
    let friends: [User]
}
