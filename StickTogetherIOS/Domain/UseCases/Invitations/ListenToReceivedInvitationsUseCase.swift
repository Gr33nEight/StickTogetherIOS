//
//  ListenToSentInvitations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

final class ListenToReceivedInvitationsUseCase: ListenToInvitations {
    private let repository: InvitationsRepository
    private let userRepository: UserRepository
    
    init(repository: InvitationsRepository, userRepository: UserRepository) {
        self.repository = repository
        self.userRepository = userRepository
    }
    
    func stream(for id: String) -> AsyncThrowingStream<[InvitationWithUser], any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let stream = repository.listenToReceivedInvitations(for: id)
                    
                    for try await invitations in stream {
                        let userIds = invitations.map({ $0.senderId })
                        let users = try await userRepository.getUsers(with: userIds)
                        let usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
                        
                        let result = invitations.compactMap({ invitation -> InvitationWithUser? in
                            guard let user = usersById[invitation.senderId] else {
                                return nil
                            }
                            return InvitationWithUser(invitation: invitation, user: user)
                        })
                        
                        continuation.yield(result)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
