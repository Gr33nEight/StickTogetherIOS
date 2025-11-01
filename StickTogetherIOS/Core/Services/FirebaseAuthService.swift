//
//  FirebaseAuthService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase

actor FirebaseAuthService: @preconcurrency AuthServiceProtocol {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    func isSignedIn() async -> Bool {
        return auth.currentUser != nil
    }
    
    func currentUser() async -> User? {
        if let firebaseUser = auth.currentUser {
            do {
                let docRef = firestore.collection("users").document(firebaseUser.uid)
                let snapshot = try await docRef.getDocument()
                if let user: User = try snapshot.data(as: User?.self) {
                    return user
                } else {
                    return UserMapper.fromFirebaseUser(firebaseUser)
                }
            } catch {
                return UserMapper.fromFirebaseUser(firebaseUser)
            }
        }
        return nil
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        let firebaseUser = authResult.user
        
        return await currentUser() ?? UserMapper.fromFirebaseUser(firebaseUser)
    }
    
    func signUp(email: String, password: String, name: String) async throws -> User {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let firebaseUser = authResult.user
        
        if !name.isEmpty {
            let req = firebaseUser.createProfileChangeRequest()
            req.displayName = name
            try await req.commitChanges()
        }
        
        let user = UserMapper.fromFirebaseUser(firebaseUser)
        // Needs to be fixed
        try firestore.collection("users").document(user.id ?? "").setData(from: user)
        
        return user
    }
    
    func signOut() async throws {
        try auth.signOut()
    }
    
    func authStateStream() -> AsyncStream<User?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, firebaseUser in
                Task {
                    if let firebaseUser = firebaseUser {
                        do {
                            let docSnap = try await self.firestore.collection("users").document(firebaseUser.uid).getDocument()
                            if let user: User = try docSnap.data(as: User?.self) {
                                continuation.yield(user)
                            } else {
                                continuation.yield(UserMapper.fromFirebaseUser(firebaseUser))
                            }
                        } catch {
                            continuation.yield(UserMapper.fromFirebaseUser(firebaseUser))
                        }
                    } else {
                        continuation.yield(nil)
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in
                self.auth.removeStateDidChangeListener(handle)
            }
        }
    }
}
