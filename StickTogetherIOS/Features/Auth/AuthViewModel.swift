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

    // Injected dependencies
    private var authService: (any AuthServiceProtocol)?
    private var loadingManager: LoadingManager?
    private var showToastMessage: ToastMessageService = .init { _ in }

    func setup(authService: any AuthServiceProtocol,
               loading: LoadingManager? = nil,
               toast: ToastMessageService? = nil) {
        self.authService = authService
        self.loadingManager = loading
        if let toast { self.showToastMessage = toast }
        Task { await checkIfSignedIn() }
    }

    func checkIfSignedIn() async {
        guard let auth = authService else { return }
        isAuthenticated = await auth.isSignedIn()
    }

    private func execute(_ operation: @escaping @Sendable () async throws -> Void,
                         setAuthStateOnSuccess: Bool? = nil,
                         successMessage: String? = nil) async {
        guard authService != nil else { return }

        if let loader = loadingManager {
            do {
                try await loader.run { try await operation() }
                if let success = setAuthStateOnSuccess { isAuthenticated = success }
                if let message = successMessage { print(message) }
            } catch {
                showToastMessage(.failed(error.localizedDescription))
                if setAuthStateOnSuccess != nil { isAuthenticated = false }
            }
            return
        }

        do {
            try await operation()
            if let success = setAuthStateOnSuccess { isAuthenticated = success }
            if let message = successMessage { showToastMessage(.succes(message)) }
        } catch {
            showToastMessage(.failed(error.localizedDescription))
            if setAuthStateOnSuccess != nil { isAuthenticated = false }
        }
    }

    func signIn() async {
        await execute({
            guard let s = await self.authService else { return }
            _ = try await s.signIn(email: self.email, password: self.password)
        }, setAuthStateOnSuccess: true,
           successMessage: "Signed in successfully")
    }

    func signUp() async {
        await execute({
            guard let s = await self.authService else { return }
            _ = try await s.signUp(email: self.email, password: self.password, name: self.name)
        }, setAuthStateOnSuccess: true,
           successMessage: "Account created successfully")
    }

    func signOut() async {
        await execute({
            guard let s = await self.authService else { return }
            try await s.signOut()
        }, setAuthStateOnSuccess: false,
           successMessage: "Signed out successfully")
    }
    
    func resetState() {
        name = ""
        email = ""
        password = ""
        rePassword = ""
    }
}
