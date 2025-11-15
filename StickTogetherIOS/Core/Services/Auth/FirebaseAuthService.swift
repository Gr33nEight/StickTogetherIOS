//
//  FirebaseAuthService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import AuthenticationServices
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase
import GoogleSignIn

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
        //TODO: Needs to be fixed
        try firestore.collection("users").document(user.id ?? "").setData(from: user)
        
        return user
    }
    
    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
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
    
    func getUserById(_ uid: String) async throws -> User? {
        let snapshot = try await firestore.collection("users").document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    func getUserByEmail(_ email: String) async throws -> User? {
        let snapshot = try await firestore.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }.first
    }
    
    func getUsersByIds(_ uids: [String]) async throws -> [User] {
        if uids.isEmpty { return [] }
        let snapshot = try await firestore.collection("users")
            .whereField(FieldPath.documentID(), in: uids)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    func updateUser(_ user: User) async throws {
        guard let id = user.id else { throw AuthError.missingUserId }
        try firestore.collection("users").document(id).setData(from: user, merge: true)
    }
    
    func addToFriendsList(friendId: String, for userId: String) async throws {
        try await firestore.collection("users")
            .document(userId)
            .updateData([
                "friendsIds": FieldValue.arrayUnion([friendId])
            ])
    }
    
    func removeFromFriendsList(friendId: String, for userId: String) async throws {
        try await firestore.collection("users")
            .document(userId)
            .updateData([
                "friendsIds": FieldValue.arrayRemove([friendId])
            ])
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>, nonce: String) async throws -> ValueOrError<User> {
        switch result {
        case .success(let authorization):
            guard let appleID = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return .error("Invalid Apple credential")
            }
            
            guard let idTokenData = appleID.identityToken,
                  let idTokenString = String(data: idTokenData, encoding: .utf8) else {
                return .error("Unable to fetch Apple idToken or nonce")
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleID.fullName)
            
            do {
                let authResult = try await self.auth.signIn(with: credential)
                let firebaseUser = authResult.user

                // Fetch existing user if exists
                let userRef = firestore.collection("users").document(firebaseUser.uid)
                let snapshot = try? await userRef.getDocument()
                var user: User

                if let snapshot, let existingUser = try? snapshot.data(as: User.self) {
                    // Merge new info
                    user = existingUser
                    user.name = firebaseUser.displayName ?? existingUser.name
                    user.email = firebaseUser.email ?? existingUser.email
                } else {
                    // No existing user, create new
                    user = UserMapper.fromFirebaseUser(firebaseUser)
                }

                // Save user with merge: true to avoid overwriting other fields
                try userRef.setData(from: user, merge: true)
                
                return .value(user)
            } catch {
                return .error(error.localizedDescription)
            }
            
        case .failure(_):
            return .error("Something went wrong with Apple sign in")
        }
    }
    
    func signInWithGoogle() async throws -> ValueOrError<User> {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return .error("Missing Google client ID") }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewControler = await scene?.windows.first?.rootViewController else { return .error("Unable to get root view controller") }
        
        let authResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewControler)
        let googleUser = authResult.user
        guard let idToken = googleUser.idToken?.tokenString else { return .error("Unable to get idToken") }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)
        
        let result = try await self.auth.signIn(with: credential)
        let firebaseUser = result.user

        let userRef = firestore.collection("users").document(firebaseUser.uid)
        let snapshot = try? await userRef.getDocument()
        var user: User

        if let snapshot, let existingUser = try? snapshot.data(as: User.self) {
            user = existingUser
            user.name = firebaseUser.displayName ?? existingUser.name
            user.email = firebaseUser.email ?? existingUser.email
        } else {
            user = UserMapper.fromFirebaseUser(firebaseUser)
        }
        
        return .value(user)
    }
}
