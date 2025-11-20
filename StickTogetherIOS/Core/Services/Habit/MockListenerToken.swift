//
//  MockListenerToken.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//


import Foundation

actor MockListenerToken: @preconcurrency ListenerToken {
    private let removeAction: () -> Void
    init(removeAction: @escaping () -> Void) { self.removeAction = removeAction }
    func remove() { removeAction() }
}

actor MockHabitService: @preconcurrency HabitServiceProtocol {
    // in-memory store
    private var store: [String: Habit] = [:]
    private var listeners: [String: ( ([Habit]) -> Void )] = [:]
    private var nextId = 1

    // helpers
    private func makeId() -> String {
        let id = "mock-habit-\(nextId)"
        nextId += 1
        return id
    }

    private func notifyListeners() {
        let all = Array(store.values)
        for (_, cb) in listeners {
            cb(all)
        }
    }

    // MARK: CRUD

    func createHabit(_ habit: Habit) async throws -> Habit {
        var copy = habit
        if copy.id == nil || copy.id?.isEmpty == true {
            copy.id = makeId()
        }
        store[copy.id!] = copy
        notifyListeners()
        return copy
    }

    func updateHabit(_ habit: Habit) async throws {
        guard let id = habit.id else { return }
        store[id] = habit
        notifyListeners()
    }

    func deleteHabit(_ habitId: String) async throws {
        store.removeValue(forKey: habitId)
        notifyListeners()
    }

    func fetchHabit(byId id: String) async throws -> Habit? {
        return store[id]
    }

    /// returns habits where user is owner OR buddy (simple semantics for tests)
    func fetchAllHabits(for userId: String) async throws -> [Habit] {
        return store.values.filter { $0.ownerId == userId || $0.buddyId == userId }
    }

    func listenToHabits(for userId: String, update: @escaping ([Habit]) -> Void) -> ListenerToken {
        // create token id
        let tokenId = UUID().uuidString
        // wrap update so that it filters by userId (mirror fetchAllHabits semantics)
        let cb: ([Habit]) -> Void = { all in
            let filtered = all.filter { $0.ownerId == userId || $0.buddyId == userId }
            update(filtered)
        }
        listeners[tokenId] = cb

        // immediately send current snapshot filtered
        Task { @MainActor in
            let snapshot = await store.values.filter { $0.ownerId == userId || $0.buddyId == userId }
            update(snapshot)
        }

        return MockListenerToken { [weak self] in
            Task {
                // hop to the service actor context to mutate actor-isolated state
                await self?.removeListener(for: tokenId)
            }
        }
    }

    // helper runs on MockHabitService actor
    private func removeListener(for tokenId: String) {
        listeners.removeValue(forKey: tokenId)
    }

    /// updatedCompletionState now uses signature (habitId, date, userId, markCompleted)
    func updatedCompletionState(for habitId: String, date: Date, userId: String, markCompleted: Bool) async throws {
        guard var habit = store[habitId] else { throw NSError(domain: "MockHabitService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Habit not found"]) }

        let key = Habit.dayKey(for: date)
        var arr = habit.completion[key] ?? []

        if markCompleted {
            if !arr.contains(userId) { arr.append(userId) }
        } else {
            arr.removeAll { $0 == userId }
        }

        habit.completion[key] = arr
        store[habitId] = habit
        notifyListeners()
    }
}
