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
    
    func createHabit(_ habit: Habit) async throws -> Habit {
        var habitToSave = habit
        if habitToSave.id == nil {
            habitToSave.id = UUID().uuidString
        }
        try db.collection(collection)
            .document(habitToSave.id!)
            .setData(from: habitToSave)
        return habitToSave
    }
    
    func updateHabit(_ habit: Habit) async throws {
        guard let id = habit.id else { return }
        try db.collection(collection)
            .document(id)
            .setData(from: habit, merge: true)
    }
    
    func deleteHabit(_ habitId: String) async throws {
        try await db.collection(collection)
            .document(habitId)
            .delete()
    }
    
    func fetchHabit(byId id: String) async throws -> Habit? {
        let snapshot = try await db.collection(collection).document(id).getDocument()
        return try snapshot.data(as: Habit.self)
    }
    
    func fetchAllHabits(for userId: String) async throws -> [Habit] {
        let snapshot = try await db.collection(collection)
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
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
}

private struct FirestoreListenerToken: ListenerToken {
    let listener: ListenerRegistration
    func remove() {
        listener.remove()
    }
}
