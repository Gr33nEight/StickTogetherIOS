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
    private var listenerToken: ListenerToken?
    private var loadingManager: LoadingManager?
    private var currentUser: User
    
    init(service: HabitServiceProtocol,
         loading: LoadingManager? = nil,
         currentUser: User) {
        self.service = service
        self.loadingManager = loading
        self.currentUser = currentUser
    }
    
    @MainActor
    func startListening() async {
        if listenerToken != nil {
            return
        }
        await loadUserHabits()
    }

    private func loadUserHabits() async {
        guard listenerToken == nil else { return }

        do {
            if let loader = loadingManager {
                let loaded: [Habit] = try await loader.run {
                    try await self.service.fetchAllHabits(for: self.currentUser.safeID)
                }
                habits = loaded
            } else {
                habits = try await service.fetchAllHabits(for: currentUser.safeID)
            }

            listenerToken = service.listenToHabits(for: currentUser.safeID) { [weak self] newHabits in
                Task { @MainActor in
                    self?.habits = newHabits
                    await NotificationManager.shared.rescheduleAll(habits: newHabits)
                }
            }
        } catch {
            print("Failed to load habits: \(error)")
            habits = []
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
            var savedHabit: Habit? = nil
            if let loader = loadingManager {
                savedHabit = try await loader.run { [self] in
                    try await service.createHabit(habit)
                }
            } else {
                savedHabit = try await service.createHabit(habit)
            }
            
            guard let savedHabit else { return }
            
            habits.append(savedHabit)
            await NotificationManager.shared.scheduleNotifications(for: savedHabit)
            
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
            if let id = habit.id {
                await NotificationManager.shared.cancelNotifications(for: id)
                await NotificationManager.shared.scheduleNotifications(for: habit)
            }
        } catch {
            print("Failed to update habit: \(error)")
        }
    }
    
    func deleteHabit(_ habitId: String?) async -> SuccessOrError {
        guard let habitId  else {
            return .error("Couldn't find habit to delete")
        }
        do {
            if let loader = loadingManager {
                await NotificationManager.shared.cancelNotifications(for: habitId)
                if let habit = habits.first(where: { $0.id == habitId }) {
                    CalendarManager.shared.removeHabit(habit)
                }else{
                    print("dalej nic?")
                }
                try await loader.run { try await self.service.deleteHabit(habitId) }
                return .success
            } else {
                await NotificationManager.shared.cancelNotifications(for: habitId)
                if let habit = habits.first(where: { $0.id == habitId }) {
                    CalendarManager.shared.removeHabit(habit)
                }
                try await service.deleteHabit(habitId)
                return .success
            }
        } catch {
            return .error("Failed to delete habit: \(error)")
        }
    }
    
    func markHabitAsCompleted(_ habit: Habit, date: Date) async {
        guard let habitId = habit.id else { return }

        let key = Habit.dayKey(for: date)
        let users = habit.completion[key] ?? []
        let isMarked = users.contains(currentUser.safeID)

        do {
            try await service.updatedCompletionState(for: habitId, date: date, userId: currentUser.safeID, markCompleted: !isMarked)
        } catch {
            print("Failed to update completion: \(error)")
        }
    }
    
    func encourageYourBuddy() async {
        print("Encouraging buddy...")
    }
    
    func wasDone(on date: Date, habit: Habit? = nil) -> Bool {
        let isPast = date < Calendar.current.startOfDay(for: Date())
        let key = Habit.dayKey(for: date)
        var wasDone = false
        
        if let habit = habit {
            wasDone = habit.completion[key]?.contains(currentUser.safeID) ?? false
        }else{
            wasDone = isPast && habits.contains { habit in
                habit.completion[key]?.contains(currentUser.safeID) ?? false
            }
        }

        return wasDone
    }
    
    func addHabitToCalendar() {
        // add to calendar
        // But don't know for how long, we don't have end date and i am not sure i want to add that yet
    }
    
    deinit {
        listenerToken?.remove()
    }
}
