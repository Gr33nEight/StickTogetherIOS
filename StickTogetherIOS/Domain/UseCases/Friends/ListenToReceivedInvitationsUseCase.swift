//
//  ListenToSentInvitations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

final class ListenToReceivedInvitationsUseCase: ListenToInvitations {
    private let repository: InvitationsRepository
    
    init(repository: InvitationsRepository) {
        self.repository = repository
    }
    
    func stream(for id: String) -> AsyncThrowingStream<[Invitation], any Error> {
        return repository.listenToReceivedInvitations(for: id)
    }
}
