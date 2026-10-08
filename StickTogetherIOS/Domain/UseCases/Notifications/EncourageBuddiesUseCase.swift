//
//  EncourageBuddiesUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/04/2026.
//

import Foundation

protocol EncourageBuddiesUseCase {
    func execute(forUsers ids: [String], from userId: String, habitId: String) async throws
}

final class EncourageBuddiesUseCaseImpl: EncourageBuddiesUseCase {
    private let notificationsRepository: NotificationsRepository
    private let userRepository: UserRepository
    
    init(notificationsRepository: NotificationsRepository, userRepository: UserRepository) {
        self.notificationsRepository = notificationsRepository
        self.userRepository = userRepository
    }
    
    func execute(forUsers ids: [String], from userId: String, habitId: String) async throws {
        let sender = try await userRepository.getUser(withId: userId)
        
        for id in ids {
            let notification = Notification(
                senderId: userId,
                receiverId: id,
                title: "New message!",
                body: "\(sender.name) encouraged you 💪 Keep going!",
                type: .friendMessage
            )
            
            try await notificationsRepository.createNotification(notification)
        }
    }
}
