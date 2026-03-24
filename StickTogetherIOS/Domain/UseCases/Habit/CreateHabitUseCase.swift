//
//  CreateHabitUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol CreateHabitUseCase {
    func execute(_ input: CreateHabitInput, for userId: String) async throws
}

final class CreateHabitUseCaseImpl: CreateHabitUseCase {
    private let habitRepository: HabitRepository
    private let userRepository: UserRepository
    private let notificationsRepository: NotificationsRepository
    
    init(
        habitRepository: HabitRepository,
        userRepository: UserRepository,
        notificationsRepository: NotificationsRepository
    ) {
        self.habitRepository = habitRepository
        self.userRepository = userRepository
        self.notificationsRepository = notificationsRepository
    }
    
    func execute(_ input: CreateHabitInput, for userId: String) async throws {
        let habitId = UUID().uuidString
        let habit = Habit(
            id: habitId,
            title: input.title,
            icon: input.icon,
            ownerId: userId,
            frequency: input.frequency,
            startDate: input.startDate,
            endDate: input.endDate,
            reminderTime: input.reminderTime,
            type: input.type
        )
        
        try await habitRepository.createHabit(habit)
        
        if let buddyId = input.buddyId {
            let sender = try await userRepository.getUser(withId: buddyId)
            
            let notification = Notification(
                senderId: userId,
                receiverId: buddyId,
                title: "Habit invite",
                body: "\(sender.name) invited you to join a habit: \(habit.title) \(habit.icon)",
                type: .habitInvite(habitId: habitId)
            )
            try await notificationsRepository.createNotification(notification)
        }
    }
}
