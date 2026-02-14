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
    
    func signUp(email: String, password: String) async throws {
        let session = try await authClient.signUp(email: email, password: password)
        
        let newUserDto = UserDTO(
            id: session.uid,
            name: email.components(separatedBy: "@").first ?? "User",
            email: email)
        
        try firestoreClient.setData(newUserDto, for: UserEndpoint.self, id: .init(value: session.uid))
    }
    
    func signOut() throws {
        try authClient.signOut()
    }
    
    func listenSession() -> AsyncStream<UserSession> {
        AsyncStream { continuation in
            let stream = authClient.listenToAuthState()
            
            Task {
                for await session in stream {
                    guard let session else {
                        continuation.yield(.loggedOut)
                        continue
                    }

                    continuation.yield(.loggedIn(userId: session.uid))
                }
            }
        }
    }
    
}
