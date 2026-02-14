//
//  AuthClientImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//


final class AuthClientImpl: AuthClient {
    let auth: Auth
    
    init(auth: Auth = .auth()) {
        self.auth = auth
    }
    
    func signIn(email: String, password: String) async throws -> AuthSession {
        let result = try await auth.signIn(withEmail: email, password: password)
        return AuthSession(uid: result.user.uid, email: result.user.email)
    }
    
    func signUp(email: String, password: String) async throws -> AuthSession {
        let result = try await auth.createUser(withEmail: email, password: password)
        return AuthSession(uid: result.user.uid, email: result.user.email)
    }
    
    func logOut() throws {
        try auth.signOut()
    }
    
    func currectAuhSession() async throws -> AuthSession {
        guard let result = auth.currentUser else {
            throw FirestoreError.unknown
        }
        
        return AuthSession(uid: result.uid, email: result.email)
    }
    
    func listenToAuthState() async throws -> AsyncStream<AuthSession?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { authResult, error in
                if let user = authResult.currentUser {
                    continuation.yield(
                        AuthSession(uid: user.uid, email: user.email)
                    )
                }else{
                    continuation.yield(nil)
                }
            }
            continuation.onTermination = { @Sendable _ in
                self.auth.removeStateDidChangeListener(handle)
            }
        }
    }
}

