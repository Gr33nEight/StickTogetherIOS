//
//  UserDTO.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation
import FirebaseFirestore

struct UserDTO: Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var friendsIds: [String] = []
    var icon: String = "🙎‍♂️"
    var language: Language = .en
    var theme: Theme = .system
    var mainHabitType: HabitType = .coop
}
