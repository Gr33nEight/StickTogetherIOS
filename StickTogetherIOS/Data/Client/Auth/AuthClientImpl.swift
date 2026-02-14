//
//  AuthClientImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//
import FirebaseAuth

final class AuthClientImpl: AuthClient {
    let auth: Auth
    
    init(auth: Auth = .auth()) {
        self.auth = auth
    }
    
    func signIn(email: String, password: String) async throws -> AuthSession {
        let result = try await auth.signIn(withEmail: email, password: password)
        return AuthSession(uid: result.user.uid)
    }
    
    func signUp(email: String, password: String) async throws -> AuthSession {
        let result = try await auth.createUser(withEmail: email, password: password)
        return AuthSession(uid: result.user.uid)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func listenToAuthState() -> AsyncStream<AuthSession?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, user in
                if let user {
                    continuation.yield(
                        AuthSession(uid: user.uid)
                    )
                } else {
                    continuation.yield(nil)
                }
            }
            continuation.onTermination = { @Sendable _ in
                self.auth.removeStateDidChangeListener(handle)
            }
        }
    }
}

