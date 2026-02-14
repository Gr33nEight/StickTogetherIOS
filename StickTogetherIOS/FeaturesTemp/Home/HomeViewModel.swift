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
    
    @Published var pickedHabitListType: HabitListType = .myHabits
    
    @Published private(set) var visibleHabits: [Habit] = []
    @Published private(set) var error: String?
    @Published private(set) var isLoading: Bool = false
    
    private var ownedHabits: [Habit] = []
    private var buddyHabits: [Habit] = []
    private var sharedHabits: [Habit] = []
    
    private var ownedTask: Task<Void, Never>?
    private var buddyTask: Task<Void, Never>?
    private var sharedTask: Task<Void, Never>?
    
    private let currentUserId: String
    private let listenToOwnedHabits: ListenToHabitsUseCase
    private let listenToBuddyHabits: ListenToHabitsUseCase
    private let listenToSharedHabits: ListenToHabitsUseCase
    
    init(
        currentUserId: String,
        listenToOwnedHabits: ListenToHabitsUseCase,
        listenToBuddyHabits: ListenToHabitsUseCase,
        listenToSharedHabits: ListenToHabitsUseCase
    ) {
        self.currentUserId = currentUserId
        self.listenToOwnedHabits = listenToOwnedHabits
        self.listenToBuddyHabits = listenToBuddyHabits
        self.listenToSharedHabits = listenToSharedHabits
    }
    
    func startListening() {
        stopListening()
        isLoading = true
        
        ownedTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToOwnedHabits.execute(for: currentUserId)
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
                let stream = try await listenToBuddyHabits.execute(for: currentUserId)
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
                let stream = try await listenToSharedHabits.execute(for: currentUserId)
                for try await habits in stream {
                    self.sharedHabits = habits
                    self.updateVisibleHabits()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func updateVisibleHabits() {
        switch pickedHabitListType {
        case .myHabits:
            self.visibleHabits = ownedHabits + buddyHabits
        case .friendsHabits:
            self.visibleHabits = sharedHabits
        }
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
