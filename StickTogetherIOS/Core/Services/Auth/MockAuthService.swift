//
//  MockAuthService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import AuthenticationServices

actor MockAuthService: @preconcurrency AuthServiceProtocol {
    
    func signInWithGoogle() async throws -> ValueOrError<User> {
        return .error("")
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, any Error>, nonce: String) async throws -> ValueOrError<User> {
        return .error("")
    }
    
    func addToFriendsList(friendId: String, for userId: String) async throws {
        // add friendId to user's friendsIds (if not present)
        if var user = users[userId] {
            if !user.friendsIds.contains(friendId) {
                user.friendsIds.append(friendId)
                users[userId] = user
                // if this is the "storedUser" also update it
                if storedUser?.id == userId {
                    storedUser = user
                }
            }
        } else {
            // create a minimal user entry if not exists (mock behaviour)
            let new = User(id: userId, name: "User \(userId.prefix(6))", email: "\(userId)@example.local", friendsIds: [friendId])
            users[userId] = new
            if storedUser?.id == userId { storedUser = new }
        }
        // if friend exists, ensure reciprocal (optional — mock keeps one-sided by default)
    }
    
    func removeFromFriendsList(friendId: String, for userId: String) async throws {
        if var user = users[userId] {
            user.friendsIds.removeAll { $0 == friendId }
            users[userId] = user
            if storedUser?.id == userId { storedUser = user }
        }
    }
    
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
        users[user.id ?? UUID().uuidString] = user
        if storedUser?.id == user.id {
            storedUser = user
        }
    }
    
    private var authStateContinuation: AsyncStream<User?>.Continuation?

    // simple in-memory user store
    private var storedUser: User? = nil {
        didSet {
            // push update to any listeners
            authStateContinuation?.yield(storedUser)
        }
    }

    // extra in-memory users map for mock lookups
    private var users: [String: User] = [:]

    // MARK: - AuthServiceProtocol (Mock implementations)

    func signUp(email: String, password: String, name: String) async throws -> User {
        // simple validation
        guard !email.isEmpty,
              !password.isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.invalidCredentials
        }

        // create a mock user
        let user = User(id: UUID().uuidString, name: name, email: email, friendsIds: [])
        storedUser = user
        users[user.id!] = user
        return user
    }

    func authStateStream() -> AsyncStream<User?> {
        return AsyncStream<User?> { continuation in
            // finish old continuation if present
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
        let user = User(id: UUID().uuidString,
                        name: email.components(separatedBy: "@").first ?? "User",
                        email: email,
                        friendsIds: [])
        storedUser = user
        users[user.id!] = user
        return user
    }

    func signOut() async throws {
        storedUser = nil
    }
}
