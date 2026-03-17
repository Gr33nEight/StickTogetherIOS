//
//  UpdateHabitUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol UpdateHabitUseCase {
    func execute(_ habit: Habit) async throws
}

final class UpdateHabitUseCaseImpl: UpdateHabitUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func execute(_ habit: Habit) async throws {
        try await repository.updateHabit(habit)
    }
}
