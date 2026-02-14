//
//  SignOutUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol SignOutUseCase {
    func execute() throws
}

final class SignOutUseCaseImpl: SignOutUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute() throws {
        try repository.signOut()
    }
}
