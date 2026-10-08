//
//  SendInvitationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol SendInvitationUseCase {
    func execute(from senderId: String, to email: String) async throws
}

final class SendInvitationUseCaseImpl: SendInvitationUseCase {
    private let invitationsRepository: InvitationsRepository
    private let userReporitory: UserRepository
    private let notificationsRepository: NotificationsRepository
    
    init(invitationsRepository: InvitationsRepository, userReporitory: UserRepository, notificationsRepository: NotificationsRepository) {
        self.invitationsRepository = invitationsRepository
        self.userReporitory = userReporitory
        self.notificationsRepository = notificationsRepository
    }
    
    func execute(from senderId: String, to email: String) async throws {
        let sender = try await userReporitory.getUser(withId: senderId)
        guard
            let receiver = try await userReporitory.getUser(byEmail: email),
            let receiverId = receiver.id
        else {
            throw InvitationError.userNotFound
        }
        
        guard senderId != receiverId else {
            throw InvitationError.cannotInviteYourself
        }
        
        let invitations = try await invitationsRepository.invitationBetween(userA: senderId, userB: receiverId)
        
        guard let invitation = invitations.first else {
            let invitation = Invitation(senderId: senderId, receiverId: receiverId)
            try await invitationsRepository.sendInvitation(invitation)
            
            let notification = Notification(
                senderId: senderId,
                receiverId: receiverId,
                title: "New friend request",
                body: "\(sender.name.capitalized) sent you a friend request",
                type: .friendRequest
            )
            
            try await notificationsRepository.createNotification(notification)
            
            return
        }
        
        if invitation.senderId == senderId {
            throw InvitationError.invitationAlreadySent
        }else{
            throw InvitationError.invitationAlreadyReceived
        }
    }
}

enum InvitationError: Error {
    case userNotFound
    case invitationAlreadySent
    case invitationAlreadyReceived
    case cannotInviteYourself
}
