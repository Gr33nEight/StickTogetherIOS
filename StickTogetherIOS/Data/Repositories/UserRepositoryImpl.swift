//
//  ProfileRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

final class UserRepositoryImpl: UserRepository {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func getUser(with userId: String) async throws -> User {
        let dto = try await firestoreClient.fetchDocument(UserEndpoint.self, id: .init(value: userId))
        return UserMapper.toDomain(dto)
    }
    
    func getUsers(with userIds: [String]) async throws -> [User] {
        guard !userIds.isEmpty else { return [] }
    
        let query = FirestoreQuery().isIn(.documentId, userIds.map(FirestoreValue.string(_:)))
        let userDtos = try await firestoreClient.fetch(UserEndpoint.self, query: query)
        
        return userDtos.map(UserMapper.toDomain)
    }
    
    func listenToUser(with userId: String) -> AsyncThrowingStream<User, any Error> {
        let stream = firestoreClient.listenDocument(UserEndpoint.self, id: .init(value: userId))
        return UserMapper.userStream(stream)
    }
}
