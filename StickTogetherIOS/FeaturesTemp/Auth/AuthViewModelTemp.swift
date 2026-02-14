//
//  AuthViewModelTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

@MainActor
final class AuthViewModelTemp: ObservableObject {
    private var signInUseCase: SignInUseCase
    private var signUpUseCase: SignUpUseCase
    private var signOutUseCase: SignOutUseCase
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    
    init(signInUseCase: SignInUseCase, signUpUseCase: SignUpUseCase, signOutUseCase: SignOutUseCase) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await signInUseCase.execute(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await signUpUseCase.execute(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try signOutUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
