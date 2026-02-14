//
//  FirestoreAuthClient.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation
import FirebaseAuth

protocol AuthClient {
    func signIn(email: String, password: String) async throws -> AuthSession
    func signUp(email: String, password: String) async throws -> AuthSession
    func logOut() throws
    func currectAuhSession() async throws -> AuthSession
    func listenToAuthState() async throws -> AsyncStream<AuthSession?>
}

