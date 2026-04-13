//
//  ListenToHabitUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/04/2026.
//

import Foundation

protocol ListenToHabitUseCase {
    func stream(for habitId: String) async throws -> AsyncThrowingStream<Habit, any Error>
}

final class ListenToHabitUseCaseImpl: ListenToHabitUseCase {
    private let habitRepository: HabitRepository
    
    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }
    
    func stream(for habitId: String) async throws -> AsyncThrowingStream<Habit, any Error> {
        return habitRepository.listenToHabit(with: habitId)
    }
}
