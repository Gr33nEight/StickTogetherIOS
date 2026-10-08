//
//  ObserveSessionUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol ObserveSessionUseCase {
    func stream() -> AsyncStream<UserSession>
}

final class ObserveSessionUseCaseImpl: ObserveSessionUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func stream() -> AsyncStream<UserSession> {
        repository.listenSession()
    }
}
