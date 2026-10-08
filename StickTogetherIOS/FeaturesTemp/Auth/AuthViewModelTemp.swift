//
//  AuthViewModelTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import UIKit

@MainActor
final class AuthViewModelTemp: ObservableObject {
    private var signInUseCase: SignInUseCase
    private var signUpUseCase: SignUpUseCase
    private var signOutUseCase: SignOutUseCase
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    private var currentNonce: String?
    
    init(signInUseCase: SignInUseCase, signUpUseCase: SignUpUseCase, signOutUseCase: SignOutUseCase) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
    }
    
    func signIn(email: String, password: String) async {
        await perform { try await signInUseCase.execute(email: email, password: password) }
    }

    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        isLoading = true
        error = nil
        let nonce = Constants.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Constants.sha256(nonce)
    }

    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        await perform {
            let authorization = try result.get()
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else { throw AuthError.invalidCredential }
            let name = credential.fullName.map { PersonNameComponentsFormatter().string(from: $0) }
            try await signInUseCase.executeApple(
                identityToken: identityToken,
                nonce: nonce,
                name: name,
                email: credential.email
            )
            currentNonce = nil
        }
    }

    func handleGoogleSignInResult(presenting viewController: UIViewController) async {
        await perform {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            guard let idToken = result.user.idToken?.tokenString else { throw AuthError.invalidCredential }
            try await signInUseCase.executeGoogle(
                idToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
        }
    }

    private func perform(_ action: () async throws -> Void) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do { try await action() }
        catch { self.error = error.localizedDescription }
    }

    func signUp(email: String, password: String, name: String) async {
        await perform { try await signUpUseCase.execute(email: email, password: password, name: name) }
    }
    
    func signOut() {
        do {
            try signOutUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
