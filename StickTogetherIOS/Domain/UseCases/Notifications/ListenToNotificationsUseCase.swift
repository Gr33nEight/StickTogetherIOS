//
//  ListenToNotificationsUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/03/2026.
//

import Foundation

protocol ListenToNotificationsUseCase {
    func stream(for userId: String) async throws -> AsyncThrowingStream<[Notification], any Error>
}

final class ListenToNotificationsUseCaseImpl: ListenToNotificationsUseCase {
    private let notificationsRepository: NotificationsRepository
    
    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
    }
    
    func stream(for userId: String) async throws -> AsyncThrowingStream<[Notification], any Error> {
        notificationsRepository.listenToNotifications(for: userId)
    }
}
