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
        async let ownedSnap = db.collection(collection)
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()
        async let buddySnap = db.collection(collection)
            .whereField("buddyId", isEqualTo: userId)
            .getDocuments()

        let (owned, buddy) = try await (ownedSnap, buddySnap)

        let allDocs = owned.documents + buddy.documents
        var seen = Set<String>()
        var result: [Habit] = []

        for doc in allDocs {
            if let id = doc.documentID as String?,
               !seen.contains(id),
               let habit = try? doc.data(as: Habit.self) {
                seen.insert(id)
                result.append(habit)
            }
        }

        return result
    }

    func listenToHabits(for userId: String, update: @escaping ([Habit]) -> Void) -> ListenerToken {
        var latestOwned: [Habit] = []
        var latestBuddy: [Habit] = []

        func mergeAndSend() {
            var map: [String: Habit] = [:]
            for h in latestOwned { if let id = h.id { map[id] = h } }
            for h in latestBuddy { if let id = h.id { map[id] = h } }
            update(Array(map.values))
        }

        let ownedListener = db.collection(collection)
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot = snapshot else { return }
                latestOwned = snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
                mergeAndSend()
            }

        let buddyListener = db.collection(collection)
            .whereField("buddyId", isEqualTo: userId)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot = snapshot else { return }
                latestBuddy = snapshot.documents.compactMap { try? $0.data(as: Habit.self) }
                mergeAndSend()
            }

        let token = CombinedListenerToken(listeners: [ownedListener, buddyListener])
        listeners.append(token)
        return token
    }

    func updatedCompletionState(for habitId: String, date: Date, userId: String, markCompleted: Bool) async throws {
        let key = "completion.\(Habit.dayKey(for: date))"
        if markCompleted {
            try await db.collection(collection).document(habitId)
                .updateData([ key : FieldValue.arrayUnion([userId]) ])
        } else {
            try await db.collection(collection).document(habitId)
                .updateData([ key : FieldValue.arrayRemove([userId]) ])
        }
    }
}

private struct FirestoreListenerToken: ListenerToken {
    let listener: ListenerRegistration
    func remove() { listener.remove() }
}

private struct CombinedListenerToken: ListenerToken {
    let listeners: [ListenerRegistration]
    func remove() {
        for l in listeners { l.remove() }
    }
}
