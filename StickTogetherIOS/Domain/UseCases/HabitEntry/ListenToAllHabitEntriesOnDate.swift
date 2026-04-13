//
//  ListenToAllHabitEntriesOnDate.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/04/2026.
//

import Foundation

protocol ListenToAllHabitEntriesOnDate {
    func stream(date: Date, habitIds: [String]) async throws -> AsyncThrowingStream<[HabitEntry], Error>
}

final class ListenToAllHabitEntriesOnDateImpl: ListenToAllHabitEntriesOnDate {
    private let habitEntryRepository: HabitEntryRepository
    
    init(habitEntryRepository: HabitEntryRepository) {
        self.habitEntryRepository = habitEntryRepository
    }
    
    func stream(date: Date, habitIds: [String]) async throws -> AsyncThrowingStream<[HabitEntry], Error> {
        habitEntryRepository.streamEntries(date: date, habitIds: habitIds)
    }
}
