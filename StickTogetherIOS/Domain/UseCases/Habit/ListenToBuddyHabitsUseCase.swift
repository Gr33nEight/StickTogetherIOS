//
//  ListenToOwnedHabitsUseCase 2.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//


import Foundation

final class ListenToBuddyHabitsUseCase: ListenToHabitsUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func stream(for id: String) async throws -> AsyncThrowingStream<[Habit], any Error>{
        return repository.listenToBuddyHabits(for: id)
    }
}
