//
//  ProfileRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol UserRepository {
    func getUser(with userId: String) async throws -> User
    func getUsers(with userIds: [String]) async throws -> [User]
    func listenToUser(with userId: String) -> AsyncThrowingStream<User, any Error>
}
