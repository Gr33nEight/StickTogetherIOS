//
//  FirebaseProfileService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/11/2025.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase

actor FirebaseProfileService: @preconcurrency ProfileServiceProtocol {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let collection = "users"
        
    func authStateStream() -> AsyncStream<User?> {
        AsyncStream { cont in
            var userDocListener: ListenerRegistration?
            
            let handle = auth.addStateDidChangeListener { [self] _, firebaseUser in
                userDocListener?.remove()
                userDocListener = nil
                
                if let firebaseUser = firebaseUser {
                    let docRef = self.firestore.collection(collection).document(firebaseUser.uid)
                    userDocListener = docRef.addSnapshotListener { snap, error in
                        if let snap = snap, snap.exists {
                            do {
                                let user = try snap.data(as: User.self)
                                cont.yield(user)
                                return
                            } catch {
                                print("Failed to decode usser doc: \(error)")
                                cont.yield(UserMapper.fromFirebaseUser(firebaseUser))
                            }
                        }
                        cont.yield(UserMapper.fromFirebaseUser(firebaseUser))
                    }
                } else {
                    cont.yield(nil)
                }
            }
            let listener = userDocListener
            let authHandle = handle
            cont.onTermination = { @Sendable _ in
                listener?.remove()
                self.auth.removeStateDidChangeListener(authHandle)
            }
        }
    }
    
    func getUserById(_ uid: String) async throws -> User? {
        let snapshot = try await firestore.collection(collection).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    func getUserByEmail(_ email: String) async throws -> User? {
        let snapshot = try await firestore.collection(collection)
            .whereField("email", isEqualTo: email)
            .getDocuments()
        let user = snapshot.documents.compactMap { try? $0.data(as: User.self) }.first
        return user
    }
    
    func getUsersByIds(_ uids: [String]) async throws -> [User] {
        if uids.isEmpty { return [] }
        let snapshot = try await firestore.collection(collection)
            .whereField(FieldPath.documentID(), in: uids)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    func updateUser(_ user: User) async throws {
        guard let id = user.id else { throw AuthError.missingUserId }
        try firestore.collection(collection).document(id).setData(from: user, merge: true)
    }
    
    func updateUserProfileIcon(_ icon: String, forUserId uid: String?) async throws {
        guard let uid = uid else { throw AuthError.missingUserId }
        try await firestore.collection(collection).document(uid).setData(["icon" : icon], merge: true)
    }
}
