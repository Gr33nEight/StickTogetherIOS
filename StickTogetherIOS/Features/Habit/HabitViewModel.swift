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
    @Published var friendsHabits: [Habit] = []

    var lastInteraction: [String:Date] = [:]
    
    private let service: HabitServiceProtocol
    private var myHabitslistenerToken: ListenerToken?
    private var friendsHabitslistenerToken: ListenerToken?
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
        if myHabitslistenerToken != nil {
            return
        }
        await loadUserHabits()
        await loadBuddiesHabits()
    }
    
    static func configured(service: HabitServiceProtocol,
                           loading: LoadingManager? = nil,
                           currentUser: User) -> HabitViewModel {
        return HabitViewModel(service: service, loading: loading, currentUser: currentUser)
    }

    private func loadUserHabits() async {
        guard myHabitslistenerToken == nil else { return }

        do {
            if let loader = loadingManager {
                let loaded: [Habit] = try await loader.run {
                    try await self.service.fetchAllHabits(for: self.currentUser.safeID)
                }
                habits = loaded
            } else {
                habits = try await service.fetchAllHabits(for: currentUser.safeID)
            }

            myHabitslistenerToken = service.listenToMyHabits(for: currentUser.safeID) { [weak self] newHabits in
                Task { @MainActor in
                    withAnimation {
                        self?.habits = newHabits
                    }
                    await NotificationManager.shared.rescheduleAll(habits: newHabits)
                }
            }
        } catch {
            print("Failed to load habits: \(error)")
            habits = []
        }
    }
    
    private func loadBuddiesHabits() async {
        guard friendsHabitslistenerToken == nil else { return }

        do {
            if let loader = loadingManager {
                let loaded: [Habit] = try await loader.run {
                    try await self.service.fetchFriendsHabits(for: self.currentUser.safeID)
                }
                friendsHabits = loaded
            } else {
                friendsHabits = try await service.fetchFriendsHabits(for: currentUser.safeID)
            }

            friendsHabitslistenerToken = service.listenToFriendsHabits(for: currentUser.safeID) { [weak self] newHabits in
                Task { @MainActor in
                    withAnimation {
                        self?.friendsHabits = newHabits
                    }
                    await NotificationManager.shared.rescheduleAll(habits: newHabits)
                }
            }
        } catch {
            print("Failed to load habits: \(error)")
            friendsHabits = []
        }
    }
    
    func getHabitById(_ id: String) async -> ValueOrError<Habit?> {
        do {
            let habit = try await service.fetchHabit(byId: id)
            return .value(habit)
        } catch {
            return .error("Failed to load habit with id \(id): \(error)")
        }
    }
    
    func createHabit(_ habit: Habit) async -> SuccessOrError {
        do {
            var savedHabit = try await service.createHabit(habit)
            habits.append(savedHabit)
            await NotificationManager.shared.scheduleNotifications(for: savedHabit)
            return .success
        } catch {
            return .error("Failed to create habit: \(error)")
        }
    }
    
    func updateHabit(_ habit: Habit) async {
        do {
            try await service.updateHabit(habit)
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
            await NotificationManager.shared.cancelNotifications(for: habitId)
            if let habit = habits.first(where: { $0.id == habitId }) {
                CalendarManager.shared.removeHabit(habit)
            }
            try await service.deleteHabit(habitId)
            return .success
        } catch {
            return .error("Failed to delete habit: \(error)")
        }
    }
    
    func markHabitAsCompleted(_ habit: Habit, date: Date) async {
        guard let habitId = habit.id else { return }
        
        lastInteraction[habitId] = Date()
        
        let key = Habit.dayKey(for: date)
        let users = habit.completion[key] ?? []
        let isMarked = users.contains(currentUser.safeID)

        do {
            try await service.updatedCompletionState(for: habitId, date: date, userId: currentUser.safeID, markCompleted: !isMarked)
        } catch {
            print("Failed to update completion: \(error)")
        }
    }
    
    func currentUserDidComplete(_ habit: Habit, on date: Date) -> Bool {
        let key = Habit.dayKey(for: date)
        return habit.userDidComplete(currentUser.safeID, forDayKey: key)
    }
    
    func habitState(_ habit: Habit, on date: Date) -> HabitState {
        let key = Habit.dayKey(for: date)
        let isPast = date <= Calendar.current.startOfDay(for: Date())
        let isAfterStartDate = date >= Calendar.current.startOfDay(for: habit.startDate)
        
        guard isPast && isAfterStartDate && habit.isScheduled(on: date) else { return .none }
        
        return habit.completionCount(forDayKey: key) >= habit.numberOfParticipants() ? .done : .skipped
    }
    
    func habitStats(on date: Date) -> (skipped: Int, done: Int) {
        let key = Habit.dayKey(for: date)
        let isPastOrToday = date <= Calendar.current.startOfDay(for: Date())

        guard isPastOrToday else { return (skipped: 0, done: 0) }

        let relevantHabits = habits.filter { $0.frequency.occurs(on: date, startDate: $0.startDate) }
        guard !relevantHabits.isEmpty else { return (skipped: 0, done: 0) }

        var skipped = 0
        var done = 0

        for habit in relevantHabits {
            let completions = habit.completion[key] ?? []
            let participants = habit.numberOfParticipants()
            
            if completions.count >= participants {
                done += 1
            } else {
                skipped += 1
            }
        }

        return (skipped: skipped, done: done)
    }
    
    deinit {
        myHabitslistenerToken?.remove()
    }
}
