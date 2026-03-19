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
    private let friendsRepository: FriendsRepository
    private let invitationsRepository: InvitationsRepository
    
    init(friendsRepository: FriendsRepository, invitationsRepository: InvitationsRepository) {
        self.friendsRepository = friendsRepository
        self.invitationsRepository = invitationsRepository
    }
    
    func execute(invitationId: String) async throws {
        let invitation = try await invitationsRepository.getInvitation(with: invitationId)
        
        // TODO: Think of better solution for assuring that this always execute together!
        try await friendsRepository.addEachOtherAsFriends(userId: invitation.senderId, friendId: invitation.receiverId)
        try await invitationsRepository.deleteInvitation(byId: invitationId)
    }
}
