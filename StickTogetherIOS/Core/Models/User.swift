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
}

extension User {
    var safeID: String {
        id ?? "UNKNOWN_USER_ID"
    }
}
