//
//  HabitRepositoryError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//


enum HabitRepositoryError: Error {
    case habitEntryNotFound
    case failedToDelete
    case failedToFetch
    case habitIdNotFound
}
