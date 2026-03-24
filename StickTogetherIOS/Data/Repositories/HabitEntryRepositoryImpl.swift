//
//  HabitEntryRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

final class HabitEntryRepositoryImpl: HabitEntryRepository {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func saveEntry(_ entry: HabitEntry) async throws {
        let dto = HabitEntryMapper.toDTO(entry)
        let docId = "\(dto.habitId)_\(dto.userId)_\(dto.date)"
        try await firestoreClient.setData(dto, for: HabitEntryEndpoint.self, id: .init(value: docId))
    }
}
