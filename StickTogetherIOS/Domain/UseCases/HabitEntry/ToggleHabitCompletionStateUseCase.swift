//
//  MarkHabitAsCompleted.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol ToggleHabitCompletionStateUseCase {
    func execute(forHabit id: String, on date: Date, forUser uid: String) async throws
}

final class ToggleHabitCompletionStateUseCaseImpl: ToggleHabitCompletionStateUseCase {
    private let habitEntryRepository: HabitEntryRepository
    private let habitRepository: HabitRepository
    
    init(habitEntryRepository: HabitEntryRepository, habitRepository: HabitRepository) {
        self.habitEntryRepository = habitEntryRepository
        self.habitRepository = habitRepository
    }
    
    func execute(forHabit id: String, on date: Date, forUser uid: String) async throws {
        let calendar = Calendar.current
        let referenceDate = calendar.startOfDay(for: date)
        
        let existing = try await habitEntryRepository.getEntry(by: id, and: referenceDate, for: uid)
        var habit = try await habitRepository.getHabit(with: id)
        
        if existing != nil {
            try await habitEntryRepository.deleteEntry(by: id, and: referenceDate, for: uid)
            habit.allCompleted = max(0, habit.allCompleted - 1)
        } else {
            let entry = HabitEntry(
                habitId: id,
                userId: uid,
                date: referenceDate,
                status: .done
            )
            try await habitEntryRepository.saveEntry(entry)
            habit.allCompleted += 1
        }
        
        let fromDate = calendar.date(byAdding: .day, value: -90, to: referenceDate)!
        
        let entries = try await habitEntryRepository.getAllEntries(
            by: id,
            from: fromDate,
            to: referenceDate
        )
        
        let newStreak = calculateStreak(
            entries: entries,
            habit: habit,
            referenceDate: referenceDate
        )
        
        habit.currentStreak = newStreak
        habit.longestStreak = max(habit.longestStreak, newStreak)
        
        try await habitRepository.updateHabit(habit)
    }
    
    private func calculateStreak(
        entries: [HabitEntry],
        habit: Habit,
        referenceDate: Date
    ) -> Int {
        let calendar = Calendar.current
        let reference = calendar.startOfDay(for: referenceDate)
        
        let participants = Set([habit.ownerId] + habit.acceptedBuddyIds)
        
        let grouped = Dictionary(grouping: entries) {
            calendar.startOfDay(for: $0.date)
        }.mapValues { Set($0.map(\.userId)) }
        
        var streak = 0
        var cursor = reference
        
        var iterations = 0
        let maxIterations = 400
        
        while iterations < maxIterations {
            iterations += 1
            
            let occurs = habit.frequency.occurs(on: cursor, startDate: habit.startDate)
            
            if !occurs {
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor),
                      prev < cursor else { break }
                cursor = prev
                continue
            }
            
            let doneUsers = grouped[cursor] ?? []
            
            if participants.isSubset(of: doneUsers) {
                streak += 1
            } else {
                break
            }
            
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor),
                  prev < cursor else { break }
            cursor = prev
        }
        
        return streak
    }
}
