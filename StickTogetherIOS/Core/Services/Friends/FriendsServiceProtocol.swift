//
//  HabitServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//

protocol FriendsServiceProtocol {
    func sendInvitation(_ invitation: Invitation) async throws
    func deleteInvitation(byId id: String) async throws
    func fetchAllUsersInvitation(for userId: String, sent: Bool) async throws -> [Invitation]
    func addToFriendsList(friendId: String, for userId: String) async throws
    func removeFromFriendsList(friendId: String, for userId: String) async throws
}
