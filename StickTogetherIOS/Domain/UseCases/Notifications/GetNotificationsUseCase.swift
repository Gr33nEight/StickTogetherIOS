//
//  GetNotificationsUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/03/2026.
//

import Foundation

protocol GetNotificationsUseCase {
    func execute(for userId: String) async throws -> [Notification]
}

final class GetNotificationsUseCaseImpl: GetNotificationsUseCase {
    private let notificationsRepository: NotificationsRepository
    
    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
    }

    func execute(for userId: String) async throws -> [Notification] {
        return try await notificationsRepository.getNotifications(byReceiver: userId)
    }
}
