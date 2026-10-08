//
//  GetHabitByIdUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol GetHabitByIdUseCase {
    func execute(id: String) async throws -> Habit
}


final class GetHabitByIdUseCaseImpl: GetHabitByIdUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    
    func execute(id: String) async throws -> Habit {
        try await repository.getHabit(with: id)
    }
}
