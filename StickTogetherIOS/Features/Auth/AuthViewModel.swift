//
//  AuthViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//
// TODO: Somewhere far away I need to handle what happens when user is using providerr to signup and user used that email somewhere

import SwiftUI
import AuthenticationServices
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false

    var currentNonce: String?
    
    // Injected dependencies
    private var authService: (any AuthServiceProtocol)?
    private var loadingManager: LoadingManager?
    private var showToastMessage: ToastMessageService = .init { _ in }

    // Task that listens to auth state changes
    private var authStateTask: Task<Void, Never>?

    func setup(authService: any AuthServiceProtocol,
               loading: LoadingManager? = nil,
               toast: ToastMessageService? = nil) {
        self.authService = authService
        self.loadingManager = loading
        if let toast { self.showToastMessage = toast }

        // cancel previous subscriber if any
        authStateTask?.cancel()

        // start listening to auth state stream
        authStateTask = Task { [weak self] in
            guard let strong = self, let svc = strong.authService else { return }
            // first emit: current value from service + then subsequent updates from stream
            // but rely on stream for ongoing updates
            for await user in svc.authStateStream() {
                // don't use weak self here, we already captured strong
                await MainActor.run {
                    strong.currentUser = user
                    strong.isAuthenticated = (user != nil)
                }
            }
        }

        Task {
            await checkIfSignedIn()
            if let user = await authService.currentUser() {
                self.currentUser = user
            } else {
                self.currentUser = nil
            }        
        }
    }

    func checkIfSignedIn() async {
        guard let auth = authService else { return }
        isAuthenticated = await auth.isSignedIn()
    }

    private func execute(_ operation: @escaping @MainActor @Sendable () async throws -> Void,
                         setAuthStateOnSuccess: Bool? = nil,
                         successMessage: String? = nil) async {
        guard authService != nil else { return }

        if let loader = loadingManager {
            do {
                try await loader.run { try await operation() }
//                if let success = setAuthStateOnSuccess { isAuthenticated = success }
//                if let message = successMessage { print(message) }
            } catch {
                showToastMessage(.failed(error.localizedDescription))
                if setAuthStateOnSuccess != nil { isAuthenticated = false }
            }
            return
        }

        do {
            try await operation()
//            if let success = setAuthStateOnSuccess { isAuthenticated = success }
//            if let message = successMessage { showToastMessage(.succes(message)) }
        } catch {
            showToastMessage(.failed(error.localizedDescription))
            if setAuthStateOnSuccess != nil { isAuthenticated = false }
        }
    }

    func signIn(email: String, password: String) async {
        await execute({
            guard let s = self.authService else { return }
            let user = try await s.signIn(email: email, password: password)
            // set currentUser immediately (stream will also emit)
            self.currentUser = user
            await self.onUserLoggedIn()
        }, setAuthStateOnSuccess: true,
           successMessage: "Signed in successfully")
    }

    func signUp(email: String, password: String, name: String) async {
        await execute({
            guard let s = self.authService else { return }
            let user = try await s.signUp(email: email, password: password, name: name)
            // set currentUser immediately
            self.currentUser = user
            await self.onUserLoggedIn()
        }, setAuthStateOnSuccess: true,
           successMessage: "Account created successfully")
    }

    func signOut() async {
        await execute({
            guard
                let s = self.authService,
                let token = UserDefaults.standard.string(forKey: "fcm_token"),
                let userId = self.currentUser?.id
            else { return print("token, service albo userId") }
            try await s.signOut()
            try? await s.updateUsersToken(userId: userId, token: token, remove: true)
            // ensure UI reflects sign out immediately
            self.currentUser = nil
            await self.onUserLoggedIn()
        }, setAuthStateOnSuccess: false,
           successMessage: "Signed out successfully")
    }

    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        await execute ({
            guard let s = self.authService,
                  let currentNonce = self.currentNonce
            else { return }
            let result = try await s.signInWithApple(result, nonce: currentNonce)
            switch result {
            case .value(let user):
                self.currentUser = user
                await self.onUserLoggedIn()
            case .error(let string):
                print(string)
            }
        }, setAuthStateOnSuccess: true, successMessage: "Signed in successfully with Apple")
    }
    
    func handleGoogleSignInResult() async {
        await execute ({
            guard let s = self.authService else { return }
            let result = try await s.signInWithGoogle()
            switch result {
            case .value(let user):
                self.currentUser = user
                self.isAuthenticated = true
                await self.onUserLoggedIn()
            case .error(let string):
                print(string)
            }
        }, setAuthStateOnSuccess: true, successMessage: "Signed in successfully with Google")
    }
    
    func onUserLoggedIn() async {
        guard
            let token = UserDefaults.standard.string(forKey: "fcm_token"),
            let userId = currentUser?.id
        else {
            return
        }
        try? await authService?.updateUsersToken(userId: userId, token: token, remove: false)
    }
    
    
    deinit {
        authStateTask?.cancel()
        authStateTask = nil
    }
}
