//
//  HabitServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import SwiftUI

protocol HabitServiceProtocol {
    func createHabit(_ habit: Habit) async throws -> Habit
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(_ habitId: String) async throws
    func fetchHabit(byId id: String) async throws -> Habit?
    func fetchAllHabits(for userId: String) async throws -> [Habit]
    func listenToHabits(for userId: String, update: @escaping ([Habit]) -> Void) -> ListenerToken
}

protocol ListenerToken {
    func remove()
}
