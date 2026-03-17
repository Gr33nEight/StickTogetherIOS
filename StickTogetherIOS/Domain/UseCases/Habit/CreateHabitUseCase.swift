//
//  CreateHabitUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol CreateHabitUseCase {
    func execute(_ habit: Habit) async throws
}

final class CreateHabitUseCaseImpl: CreateHabitUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func execute(_ habit: Habit) async throws {
        try await repository.createHabit(habit)
    }
}
