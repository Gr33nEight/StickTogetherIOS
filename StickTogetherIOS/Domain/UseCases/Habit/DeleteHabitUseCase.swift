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
    private let habitEntryRepository: HabitEntryRepository
    
    init(
        habitRepository: HabitRepository,
        habitEntryRepository: HabitEntryRepository
    ) {
        self.habitRepository = habitRepository
        self.habitEntryRepository = habitEntryRepository
    }
    
    func execute(_ habitId: String) async throws {
        do {
            try await habitRepository.deleteHabit(with: habitId)
        } catch {
            throw DeleteHabitError.failedToDeleteHabit
        }
        
        do {
            try await habitEntryRepository.deleteEntries(byHabit: habitId)
        } catch HabitEntryRepositoryError.habitEntriesNotFound {
            throw DeleteHabitError.notFound
        } catch {
            throw DeleteHabitError.failedToDeleteEntries
        }
    }
}
