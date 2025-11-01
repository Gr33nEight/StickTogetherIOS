//
//  MockAuthService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

actor MockAuthService: @preconcurrency AuthServiceProtocol {
    private var authStateContinuation: AsyncStream<User?>.Continuation?

    // simple in-memory user store
    private var storedUser: User? = nil {
        didSet {
            // push update to any listeners
            authStateContinuation?.yield(storedUser)
        }
    }

    // MARK: - AuthServiceProtocol (Mock implementations)

    func signUp(email: String, password: String, name: String) async throws -> User {
        // simple validation
        guard !email.isEmpty,
              !password.isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.invalidCredentials
        }

        // create a mock user
        let user = User(id: UUID().uuidString, name: name, email: email)
        storedUser = user
        return user
    }

    func authStateStream() -> AsyncStream<User?> {
        return AsyncStream<User?> { continuation in
            self.authStateContinuation?.finish()
            self.authStateContinuation = continuation

            continuation.yield(self.storedUser)
            continuation.onTermination = { @Sendable _ in
                Task { [weak self] in
                    await self?.setContinuationNil()
                }
            }
        }
    }

    private func setContinuationNil() {
        authStateContinuation = nil
    }

    func isSignedIn() async -> Bool {
        return storedUser != nil
    }

    func currentUser() async -> User? {
        return storedUser
    }

    func signIn(email: String, password: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        let user = User(id: UUID().uuidString,
                        name: email.components(separatedBy: "@").first ?? "User",
                        email: email)
        storedUser = user
        return user
    }

    func signOut() async throws {
        storedUser = nil
    }
}
