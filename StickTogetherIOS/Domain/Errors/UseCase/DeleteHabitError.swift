//
//  DeleteHabitError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//

import SwiftUI

enum DeleteHabitError: LocalizedError {
    case failedToDeleteHabit
    case failedToDeleteEntries
    case notFound

    var errorDescription: String? {
        switch self {
        case .failedToDeleteHabit:
            return "Failed to delete habit"

        case .failedToDeleteEntries:
            return "Failed to remove habit entries"

        case .notFound:
            return "Habit no longer exists"
        }
    }
}
