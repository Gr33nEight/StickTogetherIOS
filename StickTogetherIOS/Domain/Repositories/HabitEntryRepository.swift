//
//  HabitEntryRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

protocol HabitEntryRepository {
    func saveEntry(_ entry: HabitEntry) async throws
    func getEntry(by id: String, and date: Date, for userId: String) async throws -> HabitEntry?
    func getAllEntries(for userId: String, from fromDate: Date, to referenceDate: Date) async throws -> [HabitEntry]
    func getAllEntries(by id: String, from fromDate: Date, to referenceDate: Date) async throws -> [HabitEntry]
    func getAllEntries(on date: Date, for userId: String) async throws -> [HabitEntry]
    func deleteEntry(by id: String, and date: Date, for userId: String) async throws
    func deleteEntries(byHabit id: String) async throws
    func listenToEntries(of habitId: String, on date: Date) -> AsyncThrowingStream<[HabitEntry], Error>
    func streamEntries(date: Date,habitIds: [String]) -> AsyncThrowingStream<[HabitEntry], Error> 
}
