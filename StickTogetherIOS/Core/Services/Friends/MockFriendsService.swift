//
//  MockFriendsService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//


import Foundation

actor MockFriendsService: @preconcurrency FriendsServiceProtocol {
    private var store: [String: Invitation] = [:]
    private var nextId = 1

    private func makeId() -> String {
        let id = "mock-inv-\(nextId)"
        nextId += 1
        return id
    }

    func sendInvitation(_ invitation: Invitation) async throws {
        var copy = invitation
        if copy.id == nil || copy.id?.isEmpty == true {
            copy.id = makeId()
        }
        store[copy.id!] = copy
    }

    func deleteInvitation(byId id: String) async throws {
        store.removeValue(forKey: id)
    }

    func fetchAllUsersInvitation(for userId: String, sent: Bool = false) async throws -> [Invitation] {
        if sent {
            return store.values.filter { $0.senderId == userId }
        } else {
            return store.values.filter { $0.receiverId == userId }
        }
    }
}