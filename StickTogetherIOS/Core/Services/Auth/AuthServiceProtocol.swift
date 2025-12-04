//
//  AuthServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import Foundation
import AuthenticationServices

protocol AuthServiceProtocol {
    func isSignedIn() async -> Bool
    func currentUser() async -> User?
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, name: String) async throws -> User
    func signInWithApple(_ result: Result<ASAuthorization, Error>, nonce: String) async throws -> ValueOrError<User>
    func signInWithGoogle() async throws -> ValueOrError<User>
    func signOut() async throws
    func authStateStream() -> AsyncStream<User?>
}
