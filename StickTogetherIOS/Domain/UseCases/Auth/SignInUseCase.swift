//
//  LogInUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol SignInUseCase {
    func execute(email: String, password: String) async throws
    func executeApple(identityToken: String, nonce: String, name: String?, email: String?) async throws
    func executeGoogle(idToken: String, accessToken: String) async throws
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

    func executeApple(identityToken: String, nonce: String, name: String?, email: String?) async throws {
        try await repository.signInWithApple(identityToken: identityToken, nonce: nonce, name: name, email: email)
    }

    func executeGoogle(idToken: String, accessToken: String) async throws {
        try await repository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}

enum AuthError: Error {
    case invalidEmail
    case invalidPassword
    case weakPassword
    case invalidCredential
}
