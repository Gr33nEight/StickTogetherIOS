//
//  ListenToUserUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//


protocol ListenToFriendsUseCase {
    func stream(for userId: String) -> AsyncThrowingStream<[User], any Error>
}

final class ListenToFriendsUseCaseImpl: ListenToFriendsUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func stream(for userId: String) -> AsyncThrowingStream<[User], any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await user in repository.listenToUser(with: userId) {
                        let ids = user.friendsIds
                        
                        if ids.isEmpty {
                            continuation.yield([])
                            continue
                        }
                        
                        let friends = try await repository.getUsers(with: ids)
                        
                        continuation.yield(friends)
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
