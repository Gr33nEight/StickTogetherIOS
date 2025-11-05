//
//  AuthServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import Foundation

protocol AuthServiceProtocol {
    func isSignedIn() async -> Bool
    func currentUser() async -> User?
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, name: String) async throws -> User
    func signOut() async throws
    func authStateStream() -> AsyncStream<User?>
    
    func getUserById(_ uid: String) async throws -> User?
    func getUserByEmail(_ email: String) async throws -> User?
    func getUsersByIds(_ uids: [String]) async throws -> [User]
    func updateUser(_ user: User) async throws
    
    func addToFriendsList(friendId: String, for userId: String) async throws
    func removeFromFriendsList(friendId: String, for userId: String) async throws
}
