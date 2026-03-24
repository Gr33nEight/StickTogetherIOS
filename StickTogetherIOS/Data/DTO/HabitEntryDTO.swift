//
//  HabitEntryDTO.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation
import FirebaseFirestore

struct HabitEntryDTO: Codable, Equatable {
    @DocumentID var id: String? = nil
    var habitId: String
    var userId: String
    var date: Date
    var status: Int
}
