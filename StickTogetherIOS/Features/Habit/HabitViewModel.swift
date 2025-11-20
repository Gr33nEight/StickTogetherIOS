//
//  HabitViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [
//        Habit(id: "1", title: "Test", icon: "🔥", ownerId: "", frequency: Frequency.daily(), type: .Alone),
        Habit(id: "2", title: "Test 2", icon: "🌈", ownerId: "", frequency: Frequency.daily(), type: .coop),
        Habit(id: "4", title: "Test 4", icon: "🔁", ownerId: "", frequency: Frequency.daily(), type: .coop),
        Habit(id: "5", title: "Test 5", icon: "📊", ownerId: "", frequency: Frequency.daily(), type: .coop),
        Habit(id: "3", title: "Test 3", icon: "🏋️‍♀️", ownerId: "321", buddyId: "123", frequency: Frequency.daily(), type: .preview),
        Habit(id: "6", title: "Test 6", icon: "🥺", ownerId: "321", buddyId: "123", frequency: Frequency.daily(), type: .preview),
    ]
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
    
    func currentUserDidComplete(_ habit: Habit, on date: Date) -> Bool {
        let key = Habit.dayKey(for: date)
        return habit.userDidComplete(currentUser.safeID, forDayKey: key)
    }
    
    func habitState(_ habit: Habit, on date: Date) -> HabitState {
        let key = Habit.dayKey(for: date)
        let isPast = date < Calendar.current.startOfDay(for: Date())
        let isAfterStartDate = date >= habit.startDate
        
        guard isPast && isAfterStartDate else { return .none }
        
        return habit.completionCount(forDayKey: key) >= habit.numberOfParticipants() ? .done : .skipped
    }
    
    func habitState(on date: Date) -> HabitState {
        let key = Habit.dayKey(for: date)
        let isPast = date <= Calendar.current.startOfDay(for: Date())

        guard isPast else { return .none }
        
        let isToday = Calendar.current.isDateInToday(date)
        let hasNoCompletionsYet = habits.allSatisfy { $0.completion[key]?.isEmpty ?? true }

        if isToday && hasNoCompletionsYet {
            return .none
        }
        
        let relevant = habits.filter { $0.frequency.occurs(on: date, startDate: $0.startDate) }
        if relevant.isEmpty { return .none }
        
        let anyIncomplete = relevant.contains { $0.completionCount(forDayKey: key) < $0.numberOfParticipants() }
        
        return anyIncomplete ? .skipped : .done
    }
    
    deinit {
        listenerToken?.remove()
    }
}
