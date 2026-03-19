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
    private let friendsRepository: FriendsRepository
    
    init(friendsRepository: FriendsRepository) {
        self.friendsRepository = friendsRepository
    }
    
    func execute(userId: String, friendId: String) async throws {
        try await friendsRepository.removeEachOtherFromFriends(userId: userId, friendId: friendId)
    }
}
