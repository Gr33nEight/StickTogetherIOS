//
//  RemoveFriendUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol RemoveFriendUseCase {
    func execute(userId: String, friendId: String) async throws
}

final class RemoveFriendUseCaseImpl: RemoveFriendUseCase {
    private let transactionFactory: TransactionFactory
    private let friendsRepository: FriendsRepository
    
    init(transactionFactory: TransactionFactory, friendsRepository: FriendsRepository) {
        self.transactionFactory = transactionFactory
        self.friendsRepository = friendsRepository
    }
    
    func execute(userId: String, friendId: String) async throws {
        try await transactionFactory.run { [weak self] ctx in
            guard let self else { return }
            try friendsRepository.removeFromFriendsList(transactionContext: ctx, userId: userId, friendId: friendId)
            try friendsRepository.removeFromFriendsList(transactionContext: ctx, userId: friendId, friendId: userId)
        }
    }
}
