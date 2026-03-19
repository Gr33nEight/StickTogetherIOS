//
//  GetUserUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol GetUserUseCase {
    func byId(with userId: String) async throws -> User
    func byEmail(with email: String) async throws -> User?
}

final class GetUserUseCaseImpl: GetUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func byId(with userId: String) async throws -> User {
        try await userRepository.getUser(withId: userId)
    }
    
    func byEmail(with email: String) async throws -> User? {
        try await userRepository.getUser(byEmail: email)
    }
}
