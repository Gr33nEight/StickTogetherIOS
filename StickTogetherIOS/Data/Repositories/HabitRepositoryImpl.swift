//
//  HabitRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import FirebaseFirestore

final class HabitRepositoryImpl: HabitRepository {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func getOwnedHabits(for userId: String) async throws -> [Habit] {
        let query = FirestoreQuery().isEqual(.field("ownerId"), .string(userId))
        let dtos = try await firestoreClient.fetch(HabitEndpoint.self, query: query)
        return dtos.map({ HabitMapper.toDomain($0) })
    }
    
    func getBuddyHabits(for userId: String) async throws -> [Habit] {
        let query = FirestoreQuery().isEqual(.field("buddyId"), .string(userId))
        let dtos = try await firestoreClient.fetch(HabitEndpoint.self, query: query)
        return dtos.map({ HabitMapper.toDomain($0) })
    }
    
    func getHabit(with id: String) async throws -> Habit {
        let dto = try await firestoreClient.fetchDocument(HabitEndpoint.self, id: FirestoreDocumentID(value: id))
        return HabitMapper.toDomain(dto)
    }
    
    func deleteHabit(with id: String) async throws {
        try await firestoreClient.delete(HabitEndpoint.self, id: FirestoreDocumentID(value: id))
    }
    
    func updateHabit(_ newValue: Habit) async throws {
        let dto = HabitMapper.toDTO(newValue)
        guard let dtoId = dto.id else {
            throw FirestoreError.unknown
        }
        let docId = FirestoreDocumentID(value: dtoId)
        
        try await firestoreClient.setData(dto, for: HabitEndpoint.self, id: docId, merge: true)
    }
    
    func updateData(with id: String, updates: HabitUpdates) async throws {
        var fields: [String: FirestoreUpdateOperations] = [:]
        
        switch updates {
        case .completionState(let date, let userId):
            fields["completion.\(Habit.dayKey(for: date))"] = FirestoreUpdateOperations.union([userId])
        }
        
        try await firestoreClient.updateData(for: HabitEndpoint.self, id: .init(value: id), fields)
    }
    
    func createHabit(_ habit: Habit) async throws {
        let dto = HabitMapper.toDTO(habit)
        let docId = try await firestoreClient.create(dto, for: HabitEndpoint.self)
        try await firestoreClient.setData(dto, for: HabitEndpoint.self, id: docId, merge: false)
        
    }
    
    func listenToOwnedHabits(for userId: String) -> AsyncThrowingStream<[Habit], any Error> {
        let query = FirestoreQuery().isEqual(.field("ownerId"), .string(userId))
        let stream = firestoreClient.listen(HabitEndpoint.self, query: query)
        return HabitMapper.habitStream(stream)
    }
    
    func listenToBuddyHabits(for userId: String) -> AsyncThrowingStream<[Habit], any Error> {
        let query = FirestoreQuery().isEqual(.field("buddyId"), .string(userId))
        let stream = firestoreClient.listen(HabitEndpoint.self, query: query)
        return HabitMapper.habitStream(stream)
    }
    
    func listenToSharedHabits(for userId: String) -> AsyncThrowingStream<[Habit], any Error> {
        let query = FirestoreQuery().isEqual(.field("buddyId"), .string(userId)).isEqual(.field("type"), .int(2))
        let stream = firestoreClient.listen(HabitEndpoint.self, query: query)
        return HabitMapper.habitStream(stream) 
    }
}
