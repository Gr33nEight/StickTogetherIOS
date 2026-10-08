//
//  HabitViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/04/2026.
//

import Foundation
import SwiftUI

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var event: HabitViewEvent?
    
    @Published private(set) var habit: Habit
    @Published private(set) var entries: [HabitEntry] = []
    @Published private(set) var buddies: [User] = []
    @Published private(set) var error: String?
    
    var selectedDate: Date
    
    private var habitTask: Task<Void, Never>?
    private var habitEntriesTask: Task<Void, Never>?
    
    private var currentUserId: String
    private var getUser: GetUserUseCase
    private var deleteHabit: DeleteHabitUseCase
    private var encourageBuddies: EncourageBuddiesUseCase
    private var toggleHabitCompletionState: ToggleHabitCompletionStateUseCase
    private var listenToHabit: ListenToHabitUseCase
    private var listenToEntries: ListenToHabitEntriesUseCase
    
    var myEntry: HabitEntry? {
        entries.first { $0.userId == currentUserId }
    }
    
    var isDone: Bool {
        myEntry != nil
    }
    
    private var doneUserIds: Set<String> {
        Set(entries.map { $0.userId })
    }
    
    var completionState: CompletionState {
        let participants = Set([habit.ownerId] + habit.acceptedBuddyIds)
        
        if doneUserIds.isEmpty {
            return .none
        }
        
        let meDone = doneUserIds.contains(currentUserId)
        let allDone = participants.isSubset(of: doneUserIds)
        
        if allDone {
            return .all
        }
        
        if meDone && doneUserIds.count > 1 {
            return .meAndOthers
        }
        
        if meDone {
            return .onlyMe
        }
        
        return .onlyOthers
    }
    
    init(
        container: HabitViewContainer,
        currentUserId: String,
        getUserById: GetUserUseCase,
        deleteHabit: DeleteHabitUseCase,
        encourageBuddies: EncourageBuddiesUseCase,
        toggleHabitCompletionState: ToggleHabitCompletionStateUseCase,
        listenToHabit: ListenToHabitUseCase,
        listenToEntries: ListenToHabitEntriesUseCase
    ) {
        self.habit = container.habit
        self.selectedDate = container.selectedDate
        self.currentUserId = currentUserId
        self.getUser = getUserById
        self.deleteHabit = deleteHabit
        self.encourageBuddies = encourageBuddies
        self.toggleHabitCompletionState = toggleHabitCompletionState
        self.listenToHabit = listenToHabit
        self.listenToEntries = listenToEntries
    }
    
    func onAppear() async {
        guard let habitId = habit.id else { return }
        self.startListeningToHabit(habitId)
        self.startListeningToEntries(habitId)
    }
    
    func onDisappear() {
        stopListeningToHabit()
        stopListeningToHabitEntries()
    }
    
    func deleteHabit() async {
        guard let habitId = habit.id else { return }
        do {
            try await deleteHabit.execute(habitId)
            event = .dimsiss
        } catch {
            event = .showToastMessage(.failed(error.localizedDescription))
        }
    }
    
    func encourageBuddies() async {
        guard let habitId = habit.id else {
            return
        }
        do {
            try await encourageBuddies.execute(forUsers: habit.acceptedBuddyIds, from: habit.ownerId, habitId: habitId)
        } catch {
            event = .showToastMessage(.failed(error.localizedDescription))
        }
    }
    
    func toggleHabitCompletion() async {
        guard let habitId = habit.id else { return }

        let previousEntries = entries
        let wasDone = myEntry != nil

        if wasDone {
            entries.removeAll { $0.userId == currentUserId }
        } else {
            let newEntry = HabitEntry(
                habitId: habitId,
                userId: currentUserId,
                date: selectedDate,
                status: .done
            )
            
            entries = entries.filter { $0.userId != currentUserId } + [newEntry]
        }
        
        do {
            try await toggleHabitCompletionState.execute(
                forHabit: habitId,
                on: selectedDate,
                forUser: currentUserId
            )
        } catch {
            entries = previousEntries
            event = .showToastMessage(.failed(error.localizedDescription))
        }
    }

    
    private func getBuddies() async {
        guard !habit.acceptedBuddyIds.isEmpty else { return }
        do {
            let users = try await withThrowingTaskGroup(of: User.self) { group in
                for buddy in habit.acceptedBuddyIds {
                    group.addTask {
                        try await self.getUser.byId(with: buddy)
                    }
                }
                var results: [User] = []
                for try await user in group {
                    results.append(user)
                }
                return results
            }
            self.buddies = users
        } catch {
            event = .showToastMessage(.failed(error.localizedDescription))
        }
    }
    
    private func startListeningToHabit(_ habitId: String) {
        stopListeningToHabit()
        
        habitTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToHabit.stream(for: habitId)
                for try await habit in stream {
                    self.habit = habit
                }
            } catch let error as ListenToHabitError {
                event = error.event
            } catch {
                event = .showToastMessage(
                    .failed(error.localizedDescription)
                )
            }
        }
    }
    
    private func stopListeningToHabit() {
        habitTask?.cancel()
        habitTask = nil
    }
    
    private func startListeningToEntries(_ habitId: String) {
        stopListeningToHabitEntries()
        
        habitEntriesTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let stream = try await listenToEntries.stream(
                    forHabit: habitId,
                    date: selectedDate
                )
                
                for try await newEntries in stream {
                    self.entries = newEntries
                }
            } catch {
                self.event = .showToastMessage(.failed(error.localizedDescription))
            }
        }
    }
    
    private func stopListeningToHabitEntries() {
        habitEntriesTask?.cancel()
        habitEntriesTask = nil
    }
}
