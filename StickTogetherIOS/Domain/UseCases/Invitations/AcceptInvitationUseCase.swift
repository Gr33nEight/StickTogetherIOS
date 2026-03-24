//
//  AcceptInvitationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol AcceptInvitationUseCase {
    func execute(invitationId: String) async throws
}

final class AcceptInvitationUseCaseImpl: AcceptInvitationUseCase {
    private let transactionFactory: TransactionFactory
    private let invitationsRepository: InvitationsRepository
    private let friendsRepository: FriendsRepository
    private let notificationsRepository: NotificationsRepository
    
    init(
        transactionFactory: TransactionFactory,
        invitationsRepository: InvitationsRepository,
        friendsRepository: FriendsRepository,
        notificationsRepository: NotificationsRepository
    ) {
        self.transactionFactory = transactionFactory
        self.invitationsRepository = invitationsRepository
        self.friendsRepository = friendsRepository
        self.notificationsRepository = notificationsRepository
    }
    
    func execute(invitationId: String) async throws {
        let invitation = try await invitationsRepository.getInvitation(with: invitationId)
        let notification = try await notificationsRepository.getNotification(byReceiver: invitation.receiverId, and: invitation.senderId)
        
        try await transactionFactory.run { [weak self] ctx in
            guard let self else { return }
            try friendsRepository.addToFriendsList(transactionContext: ctx, userId: invitation.senderId, friendId: invitation.receiverId)
            try friendsRepository.addToFriendsList(transactionContext: ctx, userId: invitation.receiverId, friendId: invitation.senderId)
            try invitationsRepository.deleteInvitation(transactionContext: ctx, byId: invitationId)
            
            guard let notificationId = notification.id else { return }
            try notificationsRepository.deleteNotification(transactionContext: ctx, by: notificationId)
        }
    }
}


