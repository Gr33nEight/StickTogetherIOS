//
//  HabitRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation

protocol HabitRepository {
    func getOwnedHabits(for userId: String) async throws -> [Habit]
    func getBuddyHabits(for userId: String) async throws -> [Habit]
    func getHabit(with id: String) async throws -> Habit
    func deleteHabit(with id: String) async throws
    func updateHabit(_ newValue: Habit) async throws
    func updateData(with id: String, updates: HabitUpdates) async throws
    func createHabit(_ habit: Habit) async throws
    func listenToOwnedHabits(for userId: String) -> AsyncThrowingStream<[Habit], Error>
    func listenToBuddyHabits(for userId: String) -> AsyncThrowingStream<[Habit], Error>
    func listenToSharedHabits(for userId: String) -> AsyncThrowingStream<[Habit], Error>
}

enum HabitUpdates {
    case completionState(date: Date, userId: String)
}

