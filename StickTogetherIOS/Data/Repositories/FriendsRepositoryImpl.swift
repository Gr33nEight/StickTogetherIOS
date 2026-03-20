//
//  FriendsRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

final class FriendsRepositoryImpl: FriendsRepository {
    private let firestoreClient: FirestoreClient
    private let firestoreTransactionClient: FirestoreTransactionClient
    
    init(firestoreClient: FirestoreClient, firestoreTransactionClient: FirestoreTransactionClient) {
        self.firestoreClient = firestoreClient
        self.firestoreTransactionClient = firestoreTransactionClient
    }
    
    func addToFriendsList(userId: String, friendId: String) async throws {
        try await firestoreClient.updateData(
            for: UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            ["friendsIds" : FirestoreUpdateOperations.union([friendId])]
        )
    }
    
    func addToFriendsList(transactionContext: TransactionContext, userId: String, friendId: String) throws {
        try firestoreTransactionClient.update(
            UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            data: ["friendsIds" : FirestoreUpdateOperations.union([friendId])],
            transactionContext: transactionContext
        )
    }
    
    
    func removeFromFriendsList(userId: String, friendId: String) async throws {
        try await firestoreClient.updateData(
            for: UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            ["friendsIds" : FirestoreUpdateOperations.remove([friendId])]
        )
    }
    
    func removeFromFriendsList(transactionContext: TransactionContext, userId: String, friendId: String) throws {
        try firestoreTransactionClient.update(
            UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            data: ["friendsIds" : FirestoreUpdateOperations.remove([friendId])],
            transactionContext: transactionContext
        )
    }
}
