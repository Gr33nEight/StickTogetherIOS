//
//  HabitEntryRepositoryError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//

import Foundation

enum HabitEntryRepositoryError: Error {
    case habitEntryNotFound
    case habitEntriesNotFound
    case failedToDelete
    case failedToFetch
}
