//
//  User.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct User: Identifiable {
    var id: String?
    var name: String
    var email: String
    var friendsIds: [String]
    var icon: String
    var language: Language
    var theme: Theme
    var mainHabitType: HabitType
}

enum Language: String, Codable, CaseIterable {
    case en = "English"
    case pl = "Polish"
}

enum Theme: String, Codable, CaseIterable {
    case light
    case dark
    case system
}

extension User {
    var safeID: String {
        id ?? "UNKNOWN_USER_ID"
    }
}
