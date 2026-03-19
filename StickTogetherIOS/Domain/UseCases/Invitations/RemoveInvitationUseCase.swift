//
//  DeclineInvitationUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol RemoveInvitationUseCase {
    func execute(invitationId: String) async throws
}

final class RemoveInvitationUseCaseImpl: RemoveInvitationUseCase {
    private let invitationsRepository: InvitationsRepository
    
    init(invitationsRepository: InvitationsRepository) {
        self.invitationsRepository = invitationsRepository
    }
    
    func execute(invitationId: String) async throws {
        try await invitationsRepository.deleteInvitation(byId: invitationId)
    }
}
