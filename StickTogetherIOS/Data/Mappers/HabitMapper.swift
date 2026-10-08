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
            acceptedBuddyIds: dto.acceptedBuddyIds,
            invitedBuddyIds: dto.invitedBuddyIds,
            frequency: dto.frequency,
            startDate: dto.startDate,
            endDate: dto.endDate,
            reminderTime: dto.reminderTime,
            createdAt: dto.createdAt,
            type: dto.type,
            longestStreak: dto.longestStreak,
            currentStreak: dto.currentStreak,
            allCompleted: dto.allCompleted
        )
    }

    static func toDTO(_ habit: Habit) -> HabitDTO {
        HabitDTO(
            id: habit.id,
            title: habit.title,
            icon: habit.icon,
            ownerId: habit.ownerId,
            acceptedBuddyIds: habit.acceptedBuddyIds,
            invitedBuddyIds: habit.invitedBuddyIds,
            frequency: habit.frequency,
            startDate: habit.startDate,
            endDate: habit.endDate,
            reminderTime: habit.reminderTime,
            createdAt: habit.createdAt,
            type: habit.type,
            longestStreak: habit.longestStreak,
            currentStreak: habit.currentStreak,
            allCompleted: habit.allCompleted
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
    
    static func habitStream(_ stream: AsyncThrowingStream<HabitDTO, any Error>) -> AsyncThrowingStream<Habit, any Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await dto in stream {
                        continuation.yield(HabitMapper.toDomain(dto))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
