//
//  AuthRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let authClient: AuthClient
    private let firestoreClient: FirestoreClient
    
    init(authClient: AuthClient, firestoreClient: FirestoreClient) {
        self.authClient = authClient
        self.firestoreClient = firestoreClient
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await authClient.signIn(email: email, password: password)
    }

    func signInWithApple(identityToken: String, nonce: String, name: String?, email: String?) async throws {
        let session = try await authClient.signInWithApple(identityToken: identityToken, nonce: nonce)
        try await ensureUserProfile(session, fallbackName: name, fallbackEmail: email)
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let session = try await authClient.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        try await ensureUserProfile(session, fallbackName: nil, fallbackEmail: nil)
    }

    private func ensureUserProfile(_ session: AuthSession, fallbackName: String?, fallbackEmail: String?) async throws {
        do {
            _ = try await firestoreClient.fetchDocument(UserEndpoint.self, id: .init(value: session.uid))
        } catch FirestoreClientError.documentNotFound {
            let email = session.email ?? fallbackEmail ?? ""
            let name = session.name ?? fallbackName ?? email.components(separatedBy: "@").first ?? "User"
            let profile = UserDTO(id: session.uid, name: name, email: email)
            try await firestoreClient.setData(profile, for: UserEndpoint.self, id: .init(value: session.uid))
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        let session = try await authClient.signUp(email: email, password: password)
        
        let newUserDto = UserDTO(
            id: session.uid,
            name: name,
            email: email)
        
        try await firestoreClient.setData(newUserDto, for: UserEndpoint.self, id: .init(value: session.uid))
    }
    
    func signOut() throws {
        try authClient.signOut()
    }
    
    func listenSession() -> AsyncStream<UserSession> {
        AsyncStream { continuation in
            let stream = authClient.listenToAuthState()
            
            let task = Task {
                for await session in stream {
                    guard let session else {
                        continuation.yield(.loggedOut)
                        continue
                    }

                    continuation.yield(.loggedIn(userId: session.uid))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    
}
