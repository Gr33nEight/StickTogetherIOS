//
//  MarkAsReadUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/03/2026.
//

import Foundation

protocol MarkAsReadUseCase {
    func execute(for notificationId: String) async throws
}

final class MarkAsReadUseCaseImpl: MarkAsReadUseCase {
    private let notificationsRepository: NotificationsRepository
    
    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
    }
    
    func execute(for notificationId: String) async throws {
        try await notificationsRepository.markNotificationAsRead(by: notificationId)
    }
}
