//
//  HabitMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation

enum HabitMapper {

    static func toDomain(_ dto: HabitDTO) -> Habit {
        Habit(
            id: dto.id,
            title: dto.title,
            icon: dto.icon,
            ownerId: dto.ownerId,
            buddyId: dto.buddyId,
            frequency: dto.frequency,
            startDate: dto.startDate,
            endDate: dto.endDate,
            reminderTime: dto.reminderTime,
            createdAt: dto.createdAt,
            completion: dto.completion,
            type: dto.type
        )
    }

    static func toDTO(_ habit: Habit) -> HabitDTO {
        HabitDTO(
            id: habit.id,
            title: habit.title,
            icon: habit.icon,
            ownerId: habit.ownerId,
            buddyId: habit.buddyId,
            frequency: habit.frequency,
            startDate: habit.startDate,
            endDate: habit.endDate,
            reminderTime: habit.reminderTime,
            createdAt: habit.createdAt,
            completion: habit.completion,
            type: habit.type
        )
    }
    
    static func habitStream(_ stream: AsyncThrowingStream<[HabitDTO], any Error>) -> AsyncThrowingStream<[Habit], any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await dtos in stream {
                        continuation.yield(dtos.map(HabitMapper.toDomain(_:)))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
