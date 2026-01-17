//
//  MockProfileService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/11/2025.
//
import SwiftUI

actor MockProfileService: @preconcurrency ProfileServiceProtocol {

    private var storedUser: User? {
        didSet {
            authStateContinuation?.yield(storedUser)
        }
    }

    private var users: [String: User] = [:]
    private var authStateContinuation: AsyncStream<User?>.Continuation?

    // MARK: - Stream

    func authStateStream() -> AsyncStream<User?> {
        AsyncStream { continuation in
            authStateContinuation?.finish()
            authStateContinuation = continuation
            continuation.yield(storedUser)

            continuation.onTermination = { _ in
                Task { [weak self] in
                    await self?.clearContinuation()
                }
            }
        }
    }

    private func clearContinuation() {
        authStateContinuation = nil
    }

    // MARK: - Lookups

    func getUserById(_ uid: String) async throws -> User? {
        users[uid] ?? (storedUser?.id == uid ? storedUser : nil)
    }

    func getUserByEmail(_ email: String) async throws -> User? {
        if let s = storedUser, s.email == email { return s }
        return users.values.first { $0.email == email }
    }

    func getUsersByIds(_ uids: [String]) async throws -> [User] {
        uids.compactMap {
            users[$0] ?? (storedUser?.id == $0 ? storedUser : nil)
        }
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

        var user = users[uid] ?? storedUser ?? User(
            id: uid,
            name: "User \(uid.prefix(6))",
            email: "\(uid)@example.local"
        )

        user.icon = icon
        users[uid] = user
        if storedUser?.id == uid { storedUser = user }
    }

    // MARK: - Test helpers (MUST be async)

    func setStoredUser(_ user: User?) async {
        storedUser = user
    }

    func setUsers(_ map: [String: User]) async {
        users = map
    }
}
