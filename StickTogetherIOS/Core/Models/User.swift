//
//  User.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct User: Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
}
