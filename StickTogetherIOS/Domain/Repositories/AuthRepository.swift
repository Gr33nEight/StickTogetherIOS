//
//  AuthRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

protocol AuthRepository {
    func signIn(email: String, password: String) async throws
    func signInWithApple(identityToken: String, nonce: String, name: String?, email: String?) async throws
    func signInWithGoogle(idToken: String, accessToken: String) async throws
    func signUp(email: String, password: String, name: String) async throws
    func signOut() throws
    func listenSession() -> AsyncStream<UserSession>
}
