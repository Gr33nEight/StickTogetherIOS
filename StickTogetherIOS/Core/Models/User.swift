//
//  User.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var friendsIds: [String] = []
    var icon: String = "🙎‍♂️"
    
    // preferences
    var language: Language = .en
//    var notifications: Bool = true
    var theme: Theme = .system
    var mainHabitType: HabitType = .coop
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
