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
        let docId = "\(dto.habitId)_\(dto.userId)_\(dto.date.formattedDate)"
        try await firestoreClient.setData(dto, for: HabitEntryEndpoint.self, id: .init(value: docId))
    }
    
    func getEntry(by id: String, and date: Date, for userId: String) async throws -> HabitEntry? {
        let query = FirestoreQuery()
            .isEqual(.field("habitId"), .string(id))
            .isEqual(.field("date"), .date(date))
            .isEqual(.field("userId"), .string(userId))
        let results = try await firestoreClient.fetch(HabitEntryEndpoint.self, query: query)
        
        guard let dto = results.first else {
            return nil
        }
        
        return HabitEntryMapper.toDomain(dto)
    }
    
    func getAllEntries(for userId: String, from fromDate: Date, to referenceDate: Date) async throws -> [HabitEntry] {
        let query = FirestoreQuery()
            .isEqual(.field("userId"), .string(userId))
            .greaterThanOrEqualTo(.field("date"), .date(fromDate))
            .lessThanOrEqualTo(.field("date"), .date(referenceDate))
            .order(by: "date", descending: true)
        let results: [HabitEntryDTO] = try await firestoreClient.fetch(HabitEntryEndpoint.self, query: query)
        return results.map(HabitEntryMapper.toDomain(_:))
    }
    
    func getAllEntries(by id: String, from fromDate: Date, to referenceDate: Date) async throws -> [HabitEntry] {
        let query = FirestoreQuery()
            .isEqual(.field("habitId"), .string(id))
            .greaterThanOrEqualTo(.field("date"), .date(fromDate))
            .lessThanOrEqualTo(.field("date"), .date(referenceDate))
            .order(by: "date", descending: true)
        let results: [HabitEntryDTO] = try await firestoreClient.fetch(HabitEntryEndpoint.self, query: query)
        return results.map(HabitEntryMapper.toDomain(_:))
    }
    
    func getAllEntries(on date: Date, for userId: String) async throws -> [HabitEntry] {
        let query = FirestoreQuery()
            .isEqual(.field("date"), .date(date))
            .isEqual(.field("userId"), .string(userId))
        let results: [HabitEntryDTO] = try await firestoreClient.fetch(HabitEntryEndpoint.self, query: query)
        
        return results.map(HabitEntryMapper.toDomain(_:))
    }
    
    func deleteEntry(by id: String, and date: Date, for userId: String) async throws {
        let entryId = "\(id)_\(userId)_\(date.formattedDate)"
        do {
            try await firestoreClient.delete(HabitEntryEndpoint.self, id: .init(value: entryId))
        } catch FirestoreClientError.documentNotFound {
            throw HabitEntryRepositoryError.habitEntryNotFound
        } catch {
            throw HabitEntryRepositoryError.failedToDelete
        }
    }
    
    func deleteEntries(byHabit id: String) async throws {
        let query = FirestoreQuery().isEqual(.field("habitId"), .string(id))
        do {
            try await firestoreClient.batchDelete(HabitEntryEndpoint.self, query: query)
        } catch {
            throw HabitEntryRepositoryError.habitEntriesNotFound
        }
    }
    
    func listenToEntries(of habitId: String, on date: Date) -> AsyncThrowingStream<[HabitEntry], any Error> {
        let query = FirestoreQuery()
            .isEqual(.field("date"), .date(date))
            .isEqual(.field("habitId"), .string(habitId))
        let stream = firestoreClient.listen(HabitEntryEndpoint.self, query: query)
        
        return HabitEntryMapper.entryStream(stream)
    }
    
    func streamEntries(
        date: Date,
        habitIds: [String]
    ) -> AsyncThrowingStream<[HabitEntry], Error> {
        
        guard !habitIds.isEmpty else {
            return AsyncThrowingStream { $0.yield([]); $0.finish() }
        }
        
        let chunks = habitIds.chunked(into: 10)
        
        let stream = firestoreClient.listenChunked(
            HabitEntryEndpoint.self,
            chunks: chunks
        ) { chunk in
            FirestoreQuery()
                .isEqual(.field("date"), .date(date))
                .isIn(.field("habitId"), chunk.map { .string($0) })
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await dtos in stream {
                        let entries = dtos.map(HabitEntryMapper.toDomain)
                        continuation.yield(entries)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

enum HabitEntryError: Error {
    case notFound
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
