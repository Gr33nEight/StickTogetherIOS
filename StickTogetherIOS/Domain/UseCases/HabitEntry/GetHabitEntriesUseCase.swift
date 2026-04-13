//
//  GetHabitEntryUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/04/2026.
//

import Foundation

protocol GetHabitEntriesUseCase {
    func execute(habitId: String, date: Date) async throws -> [HabitEntry]
}

final class GetHabitEntriesUseCaseImpl: GetHabitEntriesUseCase {
    private let habitEntryRepository: HabitEntryRepository
    
    init(habitEntryRepository: HabitEntryRepository) {
        self.habitEntryRepository = habitEntryRepository
    }
    
    func execute(habitId: String, date: Date) async throws -> [HabitEntry] {
        try await habitEntryRepository.getAllEntries(of: habitId, on: date)
    }
}
