//
//  HabitViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private let service: HabitServiceProtocol
    private let authService: any AuthServiceProtocol
    private var listenerToken: ListenerToken?
    private var loadingManager: LoadingManager?
    
    init(service: HabitServiceProtocol,
         authService: any AuthServiceProtocol,
         loading: LoadingManager? = nil) {
        self.service = service
        self.authService = authService
        self.loadingManager = loading
    }
    
    func loadUserHabits() async {
        guard let uid = await authService.currentUser()?.id else { return }
        do {
            if let loader = loadingManager {
                let loaded: [Habit] = try await loader.run { [self] in
                    try await service.fetchAllHabits(for: uid)
                }
                habits = loaded
                listenerToken = service.listenToHabits(for: uid) { [weak self] newHabits in
                    self?.habits = newHabits
                }
            } else {
                habits = try await service.fetchAllHabits(for: uid)
                listenerToken = service.listenToHabits(for: uid) { [weak self] newHabits in
                    self?.habits = newHabits
                }
            }
        } catch {
            print("Failed to load habits: \(error)")
        }
    }
    
    func getHabitById(_ id: String) async -> Habit? {
        do {
            let habit: Habit?
            if let loader = loadingManager {
                habit = try await loader.run { try await self.service.fetchHabit(byId: id) }
            } else {
                habit = try await service.fetchHabit(byId: id)
            }
            return habit
        } catch {
            print("Failed to load habit with id \(id): \(error)")
            return nil
        }
    }
    
    func createHabit(_ habit: Habit) async {
        do {
            if let loader = loadingManager {
                let savedHabit: Habit = try await loader.run { [self] in
                    try await service.createHabit(habit)
                }
                habits.append(savedHabit)
            } else {
                let savedHabit = try await service.createHabit(habit)
                habits.append(savedHabit)
            }
        } catch {
            print("Failed to create habit: \(error)")
        }
    }
    
    func updateHabit(_ habit: Habit) async {
        do {
            if let loader = loadingManager {
                try await loader.run { [self] in
                    try await service.updateHabit(habit)
                }
            } else {
                try await service.updateHabit(habit)
            }
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = habit
            }
        } catch {
            print("Failed to update habit: \(error)")
        }
    }
    
    func deleteHabit(_ habitId: String) async {
        guard let habit = habits.first(where: { $0.id == habitId }) else {
            do {
                if let loader = loadingManager {
                    try await loader.run { try await self.service.deleteHabit(habitId) }
                } else {
                    try await service.deleteHabit(habitId)
                }
            } catch {
                print("Failed to delete habit: \(error)")
            }
            return
        }

        do {
            if let loader = loadingManager {
                try await loader.run { try await self.service.deleteHabit(habitId) }
            } else {
                try await service.deleteHabit(habitId)
            }
            habits.removeAll { $0.id == habitId }
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }
    
    func markHabitAsCompleted(_ habit: Habit, date: Date) async {
        guard let habitId = habit.id else { return }
        let state = habit.completionState(on: date)
        do {
            if let loader = loadingManager {
                try await loader.run { [self] in
                    switch state {
                    case .both:
                        try await service.updatedCompletionState(for: habitId, date: date, state: .buddy)
                    case .me:
                        try await service.updatedCompletionState(for: habitId, date: date, state: .neither)
                    case .buddy:
                        try await service.updatedCompletionState(for: habitId, date: date, state: .both)
                    case .neither:
                        try await service.updatedCompletionState(for: habitId, date: date, state: .me)
                    }
                }
            } else {
                switch state {
                case .both:
                    try await service.updatedCompletionState(for: habitId, date: date, state: .buddy)
                case .me:
                    try await service.updatedCompletionState(for: habitId, date: date, state: .neither)
                case .buddy:
                    try await service.updatedCompletionState(for: habitId, date: date, state: .both)
                case .neither:
                    try await service.updatedCompletionState(for: habitId, date: date, state: .me)
                }
            }
        } catch {
            print("Failed to update habit: \(error)")
        }
    }
    
    deinit {
        listenerToken?.remove()
    }
}
