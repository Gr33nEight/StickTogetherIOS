//
//  DeclineInvitationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/03/2026.
//

import Foundation

protocol DeclineInvitationUseCase {
    func execute(invitationId: String) async throws
}

final class DeclineInvitationUseCaseImpl: DeclineInvitationUseCase {
    private let invitationsRepository: InvitationsRepository
    private let notificationsRepository: NotificationsRepository
    private let transactionFactory: TransactionFactory
    
    init(invitationsRepository: InvitationsRepository, notificationsRepository: NotificationsRepository, transactionFactory: TransactionFactory) {
        self.invitationsRepository = invitationsRepository
        self.notificationsRepository = notificationsRepository
        self.transactionFactory = transactionFactory
    }
    
    func execute(invitationId: String) async throws {
        let invitation = try await invitationsRepository.getInvitation(with: invitationId)
        let notification = try await notificationsRepository.getNotification(byReceiver: invitation.receiverId, and: invitation.senderId)
        try await transactionFactory.run { [weak self] ctx in
            guard let self else { return }
            try invitationsRepository.deleteInvitation(transactionContext: ctx, byId: invitationId)
            
            guard let notificationId = notification.id else { return }
            try notificationsRepository.deleteNotification(transactionContext: ctx, by: notificationId)
        }
    }
}
