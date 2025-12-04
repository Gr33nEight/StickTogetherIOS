//
//  ProfileServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/11/2025.
//

import Foundation

protocol ProfileServiceProtocol {
    func authStateStream() -> AsyncStream<User?>

    func getUserById(_ uid: String) async throws -> User?
    func getUserByEmail(_ email: String) async throws -> User?
    func getUsersByIds(_ uids: [String]) async throws -> [User]
    
    func updateUser(_ user: User) async throws
    func updateUserProfileIcon(_ icon: String, forUserId uid: String?) async throws
}
