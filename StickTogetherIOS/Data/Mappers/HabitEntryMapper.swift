//
//  HabitEntryMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

enum HabitEntryMapper {
    static func toDomain(_ dto: HabitEntryDTO) -> HabitEntry {
        HabitEntry(
            id: dto.id,
            habitId: dto.habitId,
            userId: dto.userId,
            date: dto.date,
            status: mapStatus(dto)
        )
    }
    
    static func toDTO(_ domain: HabitEntry) -> HabitEntryDTO {
        HabitEntryDTO(
            id: domain.id,
            habitId: domain.habitId,
            userId: domain.userId,
            date: domain.date,
            status: domain.status.rawValue
        )
    }
    
    private static func mapStatus(_ dto: HabitEntryDTO) -> HabitEntryStatus {
        switch dto.status {
        case 0: return .done
        case 1: return .notDone
        default: return .notDone
        }
    }
    
    static func entryStream(_ stream: AsyncThrowingStream<[HabitEntryDTO], any Error>) -> AsyncThrowingStream<[HabitEntry], any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await dtos in stream {
                        continuation.yield(dtos.map(HabitEntryMapper.toDomain(_:)))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
