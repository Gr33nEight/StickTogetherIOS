//
//  DeleteHabitUseCAse.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol DeleteHabitUseCase {
    func execute(_ id: String) async throws
}

final class DeleteHabitUseCaseImpl: DeleteHabitUseCase {
    private let habitRepository: HabitRepository
    
    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }
    
    func execute(_ habitId: String) async throws {
        try await habitRepository.deleteHabit(with: habitId)
    }
}
