//
//  HabitService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/11/2025.
//

import FirebaseFirestore

actor FirebaseHabitService: @preconcurrency HabitServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "habits"
    
    private var listeners: [ListenerToken] = []
    private let loadingManager: LoadingManager?
    
    init(loading: LoadingManager? = nil) {
        self.loadingManager = loading
    }
    
    func createHabit(_ habit: Habit) async throws -> Habit {
        // Prepare an immutable snapshot with an id
        let habitToSave: Habit = {
            if habit.id != nil {
                return habit
            } else {
                var copy = habit
                copy.id = UUID().uuidString
                return copy
            }
        }()
        
        if let loader = loadingManager {
            return try await loader.run { [self, habitToSave] in
                try db.collection(collection)
                    .document(habitToSave.id!)
                    .setData(from: habitToSave)
                return habitToSave
            }
        } else {
            try db.collection(collection)
                .document(habitToSave.id!)
                .setData(from: habitToSave)
            return habitToSave
        }
    }
    
    func updateHabit(_ habit: Habit) async throws {
        guard let id = habit.id else { return }
        
        if let loader = loadingManager {
            try await loader.run { [self, id, habit] in
                try db.collection(collection)
                    .document(id)
                    .setData(from: habit, merge: true)
            }
        } else {
            try db.collection(collection)
                .document(id)
                .setData(from: habit, merge: true)
        }
    }
    
    func deleteHabit(_ habitId: String) async throws {
        if let loader = loadingManager {
            try await loader.run { [self, habitId] in
                try await db.collection(collection)
                    .document(habitId)
                    .delete()
            }
        } else {
            try await db.collection(collection)
                .document(habitId)
                .delete()
        }
    }
    
    func fetchHabit(byId id: String) async throws -> Habit? {
        if let loader = loadingManager {
            return try await loader.run { [self, id] in
                let snapshot = try await db.collection(collection).document(id).getDocument()
                return try snapshot.data(as: Habit.self)
            }
        } else {
            let snapshot = try await db.collection(collection).document(id).getDocument()
            return try snapshot.data(as: Habit.self)
        }
    }
    
    func fetchAllHabits(for userId: String) async throws -> [Habit] {
        if let loader = loadingManager {
            return try await loader.run { [self, userId] in
                let snapshot = try await db.collection(collection)
                    .whereField("ownerId", isEqualTo: userId)
                    .getDocuments()
                return snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
            }
        } else {
            let snapshot = try await db.collection(collection)
                .whereField("ownerId", isEqualTo: userId)
                .getDocuments()
            return snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
        }
    }
    
    func listenToHabits(for userId: String, update: @escaping ([Habit]) -> Void) -> ListenerToken {
        let listener = db.collection(collection)
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else { return }
                let habits = snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
                update(habits)
            }
        let token = FirestoreListenerToken(listener: listener)
        listeners.append(token)
        return token
    }
    
    func updatedCompletionState(for habitId: String, date: Date, state: CompletionState) async throws {
        let key = "completion.\(Habit.dayKey(for: date))"
        
        if let loader = loadingManager {
            try await loader.run { [self, habitId, key, state] in
                try await db.collection(collection)
                    .document(habitId)
                    .updateData([key: state.rawValue])
            }
        } else {
            try await db.collection(collection)
                .document(habitId)
                .updateData([key: state.rawValue])
        }
    }
}

private struct FirestoreListenerToken: ListenerToken {
    let listener: ListenerRegistration
    func remove() {
        listener.remove()
    }
}
