//
//  MockFriendsService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//


import Foundation

actor MockFriendsService: @preconcurrency FriendsServiceProtocol {

    // MARK: - Internal storage
    private var addedFriends: [(friendId: String, userId: String)] = []
    private var removedFriends: [(friendId: String, userId: String)] = []

    // MARK: - Public async accessors (FOR TESTS)

    func getAddedFriends() async -> [(friendId: String, userId: String)] {
        addedFriends
    }

    func getRemovedFriends() async -> [(friendId: String, userId: String)] {
        removedFriends
    }

    // MARK: - Friends API

    func addToFriendsList(friendId: String, for userId: String) async throws {
        addedFriends.append((friendId, userId))
    }

    func removeFromFriendsList(friendId: String, for userId: String) async throws {
        removedFriends.append((friendId, userId))
    }

    // MARK: - Invitations

    private var store: [String: Invitation] = [:]
    private var nextId = 1

    private func makeId() -> String {
        let id = "mock-inv-\(nextId)"
        nextId += 1
        return id
    }

    func sendInvitation(_ invitation: Invitation) async throws {
        var copy = invitation
        if copy.id == nil {
            copy.id = makeId()
        }
        store[copy.id!] = copy
    }

    func deleteInvitation(byId id: String) async throws {
        store.removeValue(forKey: id)
    }

    func fetchAllUsersInvitation(for userId: String, sent: Bool = false) async throws -> [Invitation] {
        sent
            ? store.values.filter { $0.senderId == userId }
            : store.values.filter { $0.receiverId == userId }
    }
}
