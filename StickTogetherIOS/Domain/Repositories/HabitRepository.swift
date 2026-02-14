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
    func updateHabit(with id: String, newValue: Habit) async throws
    func createHabit(_ habit: Habit) async throws
    func listenToOwnedHabits(for userId: String) async throws -> AsyncThrowingStream<[Habit], Error>
    func listenToBuddyHabits(for userId: String) async throws -> AsyncThrowingStream<[Habit], Error>
    func listenToSharedHabits(for userId: String) async throws -> AsyncThrowingStream<[Habit], Error>
}
