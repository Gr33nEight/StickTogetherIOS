//
//  MockAuthService.swift
//  StickTogetherIOS
//
//  Created by ChatGPT on 19/11/2025.
//  Mock implementation for testing purposes.
//

import Foundation
import AuthenticationServices

actor MockAuthService: @preconcurrency AuthServiceProtocol {
    // MARK: - In-memory store
    private var authStateContinuation: AsyncStream<User?>.Continuation?
    private var storedUser: User? {
        didSet { authStateContinuation?.yield(storedUser) }
    }
    /// extra in-memory users map for lookups and cross-user operations
    private var users: [String: User] = [:]

    // MARK: - Mock sign in with Google (fake)
    func signInWithGoogle() async throws -> ValueOrError<User> {
        // create or reuse a fake google user
        let id = "mock-google-\(UUID().uuidString.prefix(8))"
        let email = "google.\(id)@example.mock"
        let name = "GoogleUser\(id.suffix(4))"
        let user = User(id: id, name: name, email: email, friendsIds: [])
        // persist in in-memory store
        users[id] = user
        storedUser = user
        return .value(user)
    }

    // MARK: - Mock sign in with Apple (fake)
    func signInWithApple(_ result: Result<ASAuthorization, any Error>, nonce: String) async throws -> ValueOrError<User> {
        // We ignore the real ASAuthorization in mock — produce deterministic user
        let id = "mock-apple-\(UUID().uuidString.prefix(8))"
        let email = "apple.\(id)@example.mock"
        let name = "AppleUser\(id.suffix(4))"
        let user = User(id: id, name: name, email: email, friendsIds: [])
        users[id] = user
        storedUser = user
        return .value(user)
    }

    // MARK: - Friends list ops
    func addToFriendsList(friendId: String, for userId: String) async throws {
        // ensure user exists
        if var user = users[userId] {
            if !user.friendsIds.contains(friendId) {
                user.friendsIds.append(friendId)
                users[userId] = user
                if storedUser?.id == userId { storedUser = user }
            }
        } else {
            // create lightweight entry
            let new = User(id: userId, name: "User \(userId.prefix(6))", email: "\(userId)@example.mock", friendsIds: [friendId])
            users[userId] = new
            if storedUser?.id == userId { storedUser = new }
        }
    }

    func removeFromFriendsList(friendId: String, for userId: String) async throws {
        if var user = users[userId] {
            user.friendsIds.removeAll { $0 == friendId }
            users[userId] = user
            if storedUser?.id == userId { storedUser = user }
        }
    }

    // MARK: - Lookup helpers
    func getUsersByIds(_ uids: [String]) async throws -> [User] {
        var out: [User] = []
        for id in uids {
            if let u = users[id] {
                out.append(u)
            } else if let s = storedUser, s.id == id {
                out.append(s)
            }
        }
        return out
    }

    func getUserByEmail(_ email: String) async throws -> User? {
        return users.values.first { $0.email == email } ?? storedUser
    }

    func getUserById(_ uid: String) async throws -> User? {
        return users[uid] ?? (storedUser?.id == uid ? storedUser : nil)
    }

    func updateUser(_ user: User) async throws {
        let id = user.id ?? UUID().uuidString
        users[id] = user
        if storedUser?.id == id { storedUser = user }
    }

    // MARK: - Auth state stream
    func authStateStream() -> AsyncStream<User?> {
        AsyncStream<User?> { continuation in
            // finish previous continuation if any
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

    private func setContinuationNil() async {
        authStateContinuation = nil
    }

    // MARK: - Basic auth behaviors
    func signUp(email: String, password: String, name: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.invalidCredentials
        }
        let id = UUID().uuidString
        let user = User(id: id, name: name, email: email, friendsIds: [])
        users[id] = user
        storedUser = user
        return user
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
        if let existing = users.values.first(where: { $0.email == email }) {
            storedUser = existing
            return existing
        }
        // create a fallback user for test
        let id = UUID().uuidString
        let user = User(id: id, name: email.components(separatedBy: "@").first ?? "User", email: email, friendsIds: [])
        users[id] = user
        storedUser = user
        return user
    }

    func signOut() async throws {
        storedUser = nil
    }
}
