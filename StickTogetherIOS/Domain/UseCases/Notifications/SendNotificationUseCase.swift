//
//  SendNotificationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 20/03/2026.
//

import Foundation

protocol SendNotificationUseCase {
    func executeForUserWith(id userId: String) async throws
    func executeForUserWith(email: String) async throws
}

final class SendNotificationUseCaseImpl: SendNotificationUseCase {
    private let notificationsRepository: NotificationsRepository
    
    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
    }
    
    func executeForUserWith(id userId: String) async throws {
        
    }
    
    func executeForUserWith(email: String) async throws {
        
    }
}
