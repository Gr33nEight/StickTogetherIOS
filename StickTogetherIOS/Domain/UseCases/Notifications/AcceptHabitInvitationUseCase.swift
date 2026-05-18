//
//  AcceptHabitInvitationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/05/2026.
//

import SwiftUI

protocol AcceptHabitInvitationUseCase {
    func execute(notificationId: String, habit: Habit, currentUserId: String) async throws
}

final class AcceptHabitInvitationUseCaseImpl: AcceptHabitInvitationUseCase {
    private let notificationsRepository: NotificationsRepository
    private let habitRepository: HabitRepository
    private let transactionRepository: TransactionFactory
    private let userRepository: UserRepository
    
    init(notificationsRepository: NotificationsRepository, habitRepository: HabitRepository, transactionRepository: TransactionFactory, userRepository: UserRepository) {
        self.notificationsRepository = notificationsRepository
        self.habitRepository = habitRepository
        self.transactionRepository = transactionRepository
        self.userRepository = userRepository
    }
    
    func execute(notificationId: String, habit: Habit, currentUserId: String) async throws {
        let currentUser = try await userRepository.getUser(withId: currentUserId)
        try await transactionRepository.run { [weak self] ctx in
            guard let self else { return }
            guard let habitId = habit.id else { return }
            try notificationsRepository.deleteNotification(transactionContext: ctx, by: notificationId)
            try habitRepository.updateHabitFields(
                transactionContext: ctx,
                fields: [
                    "invitedBuddyIds": .remove([currentUserId]),
                    "acceptedBuddyIds": .union([currentUserId])
                ],
                habitId: habitId
            )
            let notification = Notification(
                senderId: currentUserId,
                receiverId: habit.ownerId,
                title: habit.title,
                body: "\(currentUser.name) accepted your invitation to \"\(habit.title)\"",
                type: .systemMessage
            )
            
            try notificationsRepository.createNotification(transactionContext: ctx, notification)
        }
    }
}
