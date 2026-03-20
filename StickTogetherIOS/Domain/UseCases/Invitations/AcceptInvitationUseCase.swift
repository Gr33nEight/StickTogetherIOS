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
    
    init(transactionFactory: TransactionFactory, invitationsRepository: InvitationsRepository, friendsRepository: FriendsRepository) {
        self.transactionFactory = transactionFactory
        self.invitationsRepository = invitationsRepository
        self.friendsRepository = friendsRepository
    }
    
    func execute(invitationId: String) async throws {
        let invitation = try await invitationsRepository.getInvitation(with: invitationId)
     
        try await transactionFactory.run { [weak self] ctx in
            guard let self else { return }
            try friendsRepository.addToFriendsList(transactionContext: ctx, userId: invitation.senderId, friendId: invitation.receiverId)
            try friendsRepository.addToFriendsList(transactionContext: ctx, userId: invitation.receiverId, friendId: invitation.senderId)
            try invitationsRepository.deleteInvitation(transactionContext: ctx, byId: invitationId)
        }
    }
}


