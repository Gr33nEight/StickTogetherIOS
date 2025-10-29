//
//  MockAuthService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

actor MockAuthService: AuthServiceProtocol {
    private var storedUser: User? = nil
    
    func isSignedIn() async -> Bool {
        return storedUser != nil
    }
    
    func currentUser() async -> User? {
        return storedUser
    }
    
    func signIn(email: String, password: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        let user = User(name: email.components(separatedBy: "@").first ?? "User", email: email)
        storedUser = user
        return user
    }
    
    func signOut() async throws {
        storedUser = nil
    }
    
    
}
