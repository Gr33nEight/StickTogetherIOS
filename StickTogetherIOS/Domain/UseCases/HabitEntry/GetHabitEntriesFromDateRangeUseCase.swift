//
//  GetHabitEntryUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/04/2026.
//

import Foundation

protocol GetHabitEntriesFromDateRangeUseCase {
    func execute(userId: String, from startDate: Date, to endDate: Date) async throws -> [HabitEntry]
}

final class GetHabitEntriesFromDateRangeUseCaseImpl: GetHabitEntriesFromDateRangeUseCase {
    private let habitEntryRepository: HabitEntryRepository
    
    init(habitEntryRepository: HabitEntryRepository) {
        self.habitEntryRepository = habitEntryRepository
    }
    
    func execute(userId: String, from startDate: Date, to endDate: Date) async throws -> [HabitEntry] {
        try await habitEntryRepository.getAllEntries(for: userId, from: startDate, to: endDate)
    }
}
