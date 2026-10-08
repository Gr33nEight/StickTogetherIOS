//
//  ListenToHabitEntriesUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/04/2026.
//

import Foundation

protocol ListenToHabitEntriesUseCase {
    func stream(forHabit habitId: String, date: Date) async throws -> AsyncThrowingStream<[HabitEntry], any Error>

}

final class ListenToHabitEntriesUseCaseImpl: ListenToHabitEntriesUseCase {
    private let habitEntryRepository: HabitEntryRepository
    
    init(habitEntryRepository: HabitEntryRepository) {
        self.habitEntryRepository = habitEntryRepository
    }
    
    func stream(forHabit habitId: String, date: Date) async throws -> AsyncThrowingStream<[HabitEntry], any Error> {
        habitEntryRepository.listenToEntries(of: habitId, on: date)
    }
}
