//
//  HomeViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var pickedHabitListType: HabitListType = .myHabits {
        didSet {
            self.updateVisibleHabits()
        }
    }
    @Published var selectedDate: Date = Date() {
        didSet {
            startListeningToAllHabitEntries()
        }
    }
    
    @Published private var currentUser: User?
    
    @Published private(set) var visibleHabits: [Habit] = []
    @Published private(set) var entries: [HabitEntry] = []
    @Published private(set) var error: String?
    @Published private(set) var isLoading: Bool = false
    
    private var ownedHabits: [Habit] = []
    private var buddyHabits: [Habit] = []
    private var sharedHabits: [Habit] = []
    
    private var ownedTask: Task<Void, Never>?
    private var buddyTask: Task<Void, Never>?
    private var sharedTask: Task<Void, Never>?
    private var habitEntriesTask: Task<Void, Never>?
    
    private let currentUserId: String
    private let listenToOwnedHabits: ListenToHabitsUseCase
    private let listenToBuddyHabits: ListenToHabitsUseCase
    private let listenToSharedHabits: ListenToHabitsUseCase
    private let getCurrentUser: GetUserUseCase
    private let toggleHabitCompletion: ToggleHabitCompletionStateUseCase
    private let listenToAllHabitEntriesOnDate: ListenToAllHabitEntriesOnDate
    
    var currentUserName: String {
        currentUser?.name ?? "Unknown user"
    }
    
    var habitItems: [HabitListItem] {
        visibleHabits.map { habit in
            HabitListItem(
                id: habit.id ?? UUID().uuidString,
                habit: habit,
                state: completionState(for: habit),
                isOwner: iAmOwner(of: habit.id)
            )
        }
    }
    
    var entriesByHabit: [String: [HabitEntry]] {
        Dictionary(grouping: entries) { $0.habitId }
    }
    
    init(
        currentUserId: String,
        listenToOwnedHabits: ListenToHabitsUseCase,
        listenToBuddyHabits: ListenToHabitsUseCase,
        listenToSharedHabits: ListenToHabitsUseCase,
        getCurrentUser: GetUserUseCase,
        toggleHabitCompletion: ToggleHabitCompletionStateUseCase,
        listenToAllHabitEntriesOnDate: ListenToAllHabitEntriesOnDate
    ) {
        self.currentUserId = currentUserId
        self.listenToOwnedHabits = listenToOwnedHabits
        self.listenToBuddyHabits = listenToBuddyHabits
        self.listenToSharedHabits = listenToSharedHabits
        self.getCurrentUser = getCurrentUser
        self.toggleHabitCompletion = toggleHabitCompletion
        self.listenToAllHabitEntriesOnDate = listenToAllHabitEntriesOnDate
    }
    
    func onAppear() async {
        startListening()
        await getCurrentUser()
    }
    
    private func startListening() {
        stopListening()
        ownedTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToOwnedHabits.stream(for: currentUserId)
                for try await habits in stream {
                    self.ownedHabits = habits
                    self.updateVisibleHabits()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
        
        buddyTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToBuddyHabits.stream(for: currentUserId)
                for try await habits in stream {
                    self.buddyHabits = habits
                    self.updateVisibleHabits()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
        
        sharedTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToSharedHabits.stream(for: currentUserId)
                for try await habits in stream {
                    self.sharedHabits = habits
                    self.updateVisibleHabits()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func getCurrentUser() async {
        do {
            currentUser = try await getCurrentUser.byId(with: currentUserId)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func toggleHabitCompletion(of habitId: String) async {
        let previousEntries = entries
        
        let entryExists = entries.contains {
            $0.habitId == habitId &&
            $0.userId == currentUserId
        }
        
        if entryExists {
            entries.removeAll {
                $0.habitId == habitId &&
                $0.userId == currentUserId
            }
        } else {
            let entry = HabitEntry(
                habitId: habitId,
                userId: currentUserId,
                date: selectedDate,
                status: .done
            )
            entries.append(entry)
        }
        
        do {
            try await toggleHabitCompletion.execute(
                forHabit: habitId,
                on: selectedDate,
                forUser: currentUserId
            )
        } catch {
            entries = previousEntries
            self.error = error.localizedDescription
        }
    }
    
    private func startListeningToAllHabitEntries() {
        stopListeningToAllHabitEntries()
        
        let habitIds = visibleHabits.compactMap { $0.id }

        habitEntriesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToAllHabitEntriesOnDate.stream(date: selectedDate, habitIds: habitIds)
                for try await entries in stream {
                    self.entries = entries
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func stopListeningToAllHabitEntries() {
        habitEntriesTask?.cancel()
        habitEntriesTask = nil
    }
    
    private func iAmOwner(of habitId: String?) -> Bool {
        ownedHabits.contains(where: { $0.id == habitId })
    }
    
    private func completionState(for habit: Habit) -> CompletionState {
        let entries = entriesByHabit[habit.id ?? ""] ?? []
        
        let participants = Set([habit.ownerId] + habit.acceptedBuddyIds)
        let doneUserIds = Set(entries.map { $0.userId })
        
        if doneUserIds.isEmpty { return .none }
        
        let meDone = doneUserIds.contains(currentUserId)
        let allDone = participants.isSubset(of: doneUserIds)
        
        if allDone { return .all }
        if meDone && doneUserIds.count > 1 { return .meAndOthers }
        if meDone { return .onlyMe }
        
        return .onlyOthers
    }
    
    private func updateVisibleHabits() {
        switch pickedHabitListType {
        case .myHabits:
            self.visibleHabits = ownedHabits + buddyHabits
        case .friendsHabits:
            self.visibleHabits = sharedHabits
        }
        startListeningToAllHabitEntries()
    }
    
    private func stopListening() {
        ownedTask?.cancel()
        buddyTask?.cancel()
        sharedTask?.cancel()
        
        ownedTask = nil
        buddyTask = nil
        sharedTask = nil
    }
    
    deinit {
        ownedTask?.cancel()
        buddyTask?.cancel()
        sharedTask?.cancel()
    }
}

struct HabitListItem: Identifiable {
    let id: String
    let habit: Habit
    let state: CompletionState
    let isOwner: Bool
}
