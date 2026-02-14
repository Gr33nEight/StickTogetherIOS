//
//  ListenToOwnedHabitsUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation

final class ListenToOwnedHabitsUseCase: ListenToHabitsUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func execute(for id: String) async throws -> AsyncThrowingStream<[Habit], any Error>{
        return try await repository.listenToOwnedHabits(for: id)
    }
}
