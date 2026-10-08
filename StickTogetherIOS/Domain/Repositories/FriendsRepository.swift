//
//  FriendsRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol FriendsRepository {
    func addToFriendsList(userId: String, friendId: String) async throws
    func addToFriendsList(transactionContext: TransactionContext, userId: String, friendId: String) throws
    func removeFromFriendsList(userId: String, friendId: String) async throws
    func removeFromFriendsList(transactionContext: TransactionContext, userId: String, friendId: String) throws
}
