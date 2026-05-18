//
//  ListenToHabitError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/05/2026.
//

import Foundation

enum ListenToHabitError: LocalizedError {
    case habitNotFound
    case permissionDenied
    case failedToListen

    var errorDescription: String? {
        switch self {
        case .habitNotFound:
            return "Habit no longer exists"

        case .permissionDenied:
            return "You don't have access to this habit"

        case .failedToListen:
            return "Failed to sync habit"
        }
    }
}

extension ListenToHabitError {
    var event: HabitViewEvent {
        switch self {

        case .habitNotFound:
            return .showToastMessage(
                .info(errorDescription ?? "Something went wrong")
            )

        case .permissionDenied:
            return .showToastMessage(
                .failed(errorDescription ?? "Something went wrong")
            )

        case .failedToListen:
            return .showToastMessage(
                .failed(errorDescription ?? "Something went wrong")
            )
        }
    }
}
