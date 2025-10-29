//
//  AuthServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import Foundation

protocol AuthServiceProtocol {
    func isSignedIn() async -> Bool
    func currentUser() async -> User?
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
}

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        }
    }
}
