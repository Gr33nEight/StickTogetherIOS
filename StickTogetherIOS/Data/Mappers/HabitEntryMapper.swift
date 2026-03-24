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
}
