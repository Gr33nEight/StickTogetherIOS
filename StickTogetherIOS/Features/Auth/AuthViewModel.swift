//
//  AuthViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rePassword: String = ""
    
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var authService: (any AuthServiceProtocol)?
    
    func setup(authService: AuthServiceProtocol) {
        self.authService = authService
        Task {
            await checkIfSignedIn()
        }
    }
    
    func checkIfSignedIn() async {
        guard let authService = authService else { return }
        isAuthenticated = await authService.isSignedIn()
    }
    
    func signIn() async {
        guard let authService = authService else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }
    
    func signOut() async {
        guard let authService = authService else { return }
        do {
            try await authService.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
