//
//  FriendsService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//

import Foundation
import FirebaseFirestore
import Firebase

actor FirebaseFriendsService: @preconcurrency FriendsServiceProtocol {
    private let collection = "invitations"
    private let usersCollection = "users"
    
    private let firestore = Firestore.firestore()
    
    init() { }
    
    func sendInvitation(_ invitation: Invitation) async throws {
        var invitationToSave = invitation
        if invitationToSave.id == nil {
            invitationToSave.id = UUID().uuidString
        }
        
        try firestore.collection(collection)
            .document(invitationToSave.id!)
            .setData(from: invitationToSave)
    }
    
    func deleteInvitation(byId id: String) async throws {
        try await firestore.collection(collection).document(id).delete()
    }
    
    func fetchAllUsersInvitation(for userId: String, sent: Bool = false) async throws -> [Invitation] {
        let field = sent ? "senderId" : "receiverId"
        let snapshot = try await firestore.collection(collection)
            .whereField(field, isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Invitation.self) }
    }
    
    func addToFriendsList(friendId: String, for userId: String) async throws {
        try await firestore.collection(usersCollection)
            .document(userId)
            .updateData([
                "friendsIds": FieldValue.arrayUnion([friendId])
            ])
    }
    
    func removeFromFriendsList(friendId: String, for userId: String) async throws {
        try await firestore.collection(usersCollection)
            .document(userId)
            .updateData([
                "friendsIds": FieldValue.arrayRemove([friendId])
            ])
    }
    
    func getFriendById(_ uid: String) async throws -> User? {
        let snapshot = try await firestore.collection(usersCollection).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
}
