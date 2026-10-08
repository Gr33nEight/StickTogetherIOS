//
//  SessionViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    
    enum SessionState {
        case loading
        case authenticated(AuthenticatedAppContainer)
        case unauthenticated(UnauthenticatedAppContainer)
    }
    
    @Published private(set) var state: SessionState = .loading
    
    private let observeSession: ObserveSessionUseCase
    private let getUser: GetUserUseCase
    private let signOut: SignOutUseCase
    private var task: Task<Void, Never>?
    private var profileValidationTask: Task<Void, Never>?
    
    init(observeSession: ObserveSessionUseCase, getUser: GetUserUseCase, signOut: SignOutUseCase) {
        self.observeSession = observeSession
        self.getUser = getUser
        self.signOut = signOut
        
        start()
    }
    
    deinit {
        task?.cancel()
        profileValidationTask?.cancel()
    }
    
    private func start() {
        task = Task { [weak self] in
            guard let self else { return }
            for await session in observeSession.stream() {
                profileValidationTask?.cancel()
                profileValidationTask = nil

                switch session {
                case .loggedOut:
                    state = .unauthenticated(UnauthenticatedAppContainer())
                case .loggedIn(let userId):
                    // Keep the authenticated UI inaccessible until the server confirms
                    // that this account still has a profile document.
                    state = .loading
                    profileValidationTask = Task { [weak self] in
                        guard let self else { return }
                        let exists = await validateUserProfile(userId: userId)
                        guard !Task.isCancelled else { return }

                        if exists {
                            state = .authenticated(AuthenticatedAppContainer(userId: userId))
                        } else {
                            state = .unauthenticated(UnauthenticatedAppContainer())
                        }
                    }
                }
            }
        }
    }

    private func validateUserProfile(userId: String) async -> Bool {
        var missingProfileResponses = 0
        var retryDelay: TimeInterval = 1

        while !Task.isCancelled {
            do {
                _ = try await getUser.byIdFromServer(with: userId)
                return true
            } catch {
                guard !Task.isCancelled else { return false }

                if let firestoreError = error as? FirestoreClientError,
                   case .documentNotFound = firestoreError {
                    missingProfileResponses += 1
                    if missingProfileResponses >= 10 {
                        signOutInvalidSession()
                        return false
                    }
                    try? await Task.sleep(nanoseconds: 200_000_000)
                } else {
                    // Network, permission, and other failures do not prove that the
                    // profile is missing. Keep the app on the loading screen and retry.
                    missingProfileResponses = 0
                    try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    retryDelay = min(retryDelay * 2, 30)
                }
            }
        }
        return false
    }

    private func signOutInvalidSession() {
        do { try signOut.execute() }
        catch { print("Failed to sign out invalid session: \(error.localizedDescription)") }
    }
}
