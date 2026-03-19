//
//  FriendsRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

final class FriendsRepositoryImpl: FriendsRepository {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func addToFriendsList(userId: String, friendId: String) async throws {
        try await firestoreClient.updateData(
            for: UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            ["friendsIds" : FirestoreUpdateOperations.union([friendId])]
        )
    }
    
    func removeFromFriendsList(userId: String, friendId: String) async throws {
        try await firestoreClient.updateData(
            for: UserEndpoint.self,
            id: FirestoreDocumentID(value: userId),
            ["friendsIds" : FirestoreUpdateOperations.remove([friendId])]
        )
    }
    
    func addEachOtherAsFriends(userId: String, friendId: String) async throws {
        try await firestoreClient.runTransaction { transaction in
            try transaction.update(UserEndpoint.self, id: FirestoreDocumentID(value: friendId), data: ["friendsIds" : .union([userId])])
            try transaction.update(UserEndpoint.self, id: FirestoreDocumentID(value: userId), data: ["friendsIds" : .union([friendId])])
        }
    }
    
    func removeEachOtherFromFriends(userId: String, friendId: String) async throws {
        try await firestoreClient.runTransaction { transaction in
            try transaction.update(UserEndpoint.self, id: FirestoreDocumentID(value: friendId), data: ["friendsIds" : .remove([userId])])
            try transaction.update(UserEndpoint.self, id: FirestoreDocumentID(value: userId), data: ["friendsIds" : .remove([friendId])])
        }
    }
}
