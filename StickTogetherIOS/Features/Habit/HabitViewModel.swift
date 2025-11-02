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
    
    init(service: HabitServiceProtocol, authService: any AuthServiceProtocol) {
        self.service = service
        self.authService = authService
        Task { await loadUserHabits() }
    }
    
    func loadUserHabits() async {
        guard let uid = await authService.currentUser()?.id else { return }
        do {
            habits = try await service.fetchAllHabits(for: uid)
            listenerToken = service.listenToHabits(for: uid) { [weak self] newHabits in
                self?.habits = newHabits
            }
        } catch {
            print("Failed to load habits: \(error)")
        }
    }
    
    func createHabit(_ habit: Habit) async {
        do {
            let savedHabit = try await service.createHabit(habit)
            habits.append(savedHabit)
        } catch {
            print("Failed to create habit: \(error)")
        }
    }
    
    func updateHabit(_ habit: Habit) async {
        do {
            try await service.updateHabit(habit)
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = habit
            }
        } catch {
            print("Failed to update habit: \(error)")
        }
    }
    
    func deleteHabit(_ habitId: String) async {
        do {
            try await service.deleteHabit(habitId)
            habits.removeAll { $0.id == habitId }
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }
    
    deinit {
        listenerToken?.remove()
    }
}
