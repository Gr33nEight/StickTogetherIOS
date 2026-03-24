//
//  HabitEntryEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

enum HabitEntryEndpoint: FirestoreEndpoint {
    typealias DTO = HabitEntryDTO
    static var path: String = "habitEntries"
}
