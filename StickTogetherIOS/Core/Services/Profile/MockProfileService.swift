//
//  MockProfileService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/11/2025.
//
import SwiftUI

actor MockProfileService: @preconcurrency ProfileServiceProtocol {
    // simple in-memory user store + stream continuation
    private var storedUser: User? {
        didSet {
            authStateContinuation?.yield(storedUser)
        }
    }
    private var users: [String: User] = [:]
    private var authStateContinuation: AsyncStream<User?>.Continuation?

    // MARK: - Stream
    func authStateStream() -> AsyncStream<User?> {
        AsyncStream<User?> { continuation in
            // finish previous continuation if any
            self.authStateContinuation?.finish()
            self.authStateContinuation = continuation

            // initial value
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

    // MARK: - Lookups

    func getUserById(_ uid: String) async throws -> User? {
        return users[uid] ?? (storedUser?.id == uid ? storedUser : nil)
    }

    func getUserByEmail(_ email: String) async throws -> User? {
        // check storedUser first, then map
        if let s = storedUser, s.email == email { return s }
        return users.values.first { $0.email == email }
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

    // MARK: - Updates

    func updateUser(_ user: User) async throws {
        let id = user.id ?? UUID().uuidString
        users[id] = user
        if storedUser?.id == id {
            storedUser = user
        }
    }

    func updateUserProfileIcon(_ icon: String, forUserId uid: String?) async throws {
        guard let uid = uid ?? storedUser?.id else { return }
        if var user = users[uid] {
            user.icon = icon
            users[uid] = user
            if storedUser?.id == uid { storedUser = user }
        } else if var s = storedUser, s.id == uid {
            s.icon = icon
            storedUser = s
            users[uid] = s
        } else {
            // create a minimal user entry in mock if not present
            let new = User(id: uid, name: "User \(uid.prefix(6))", email: "\(uid)@example.local")
            var created = new
            created.icon = icon
            users[uid] = created
        }
    }

    // MARK: - Helpers for tests (optional)
    // Use these in tests to pre-populate the mock
    func setStoredUser(_ user: User?) {
        storedUser = user
    }

    func setUsers(_ map: [String: User]) {
        users = map
    }
}
