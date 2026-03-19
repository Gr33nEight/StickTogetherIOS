//
//  ListenToFriendsUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

protocol ListenToUserUseCase {
    func stream(for userId: String) -> AsyncThrowingStream<User, any Error>
}

final class ListenToUserUseCaseImpl: ListenToUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func stream(for userId: String) -> AsyncThrowingStream<User, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await user in repository.listenToUser(with: userId) {
                        continuation.yield(user)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
