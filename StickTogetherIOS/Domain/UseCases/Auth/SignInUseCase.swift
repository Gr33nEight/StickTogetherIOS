//
//  LogInUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol SignInUseCase {
    func execute(email: String, password: String) async throws
}

final class SignInUseCaseImpl: SignInUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(email: String, password: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        try await repository.signIn(email: email, password: password)
    }
}

enum AuthError: Error {
    case invalidEmail
    case invalidPassword
    case weakPassword
}
