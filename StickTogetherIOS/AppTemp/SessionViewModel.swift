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
    
    init(observeSession: ObserveSessionUseCase, getUser: GetUserUseCase, signOut: SignOutUseCase) {
        self.observeSession = observeSession
        self.getUser = getUser
        self.signOut = signOut
        
        start()
    }
    
    deinit {
        task?.cancel()
    }
    
    private func start() {
        task = Task {
            for await session in observeSession.stream() {
                switch session {
                case .loggedOut:
                    state = .unauthenticated(UnauthenticatedAppContainer())
                case .loggedIn(let userId):
                    if await validateUserProfile(userId: userId) {
                        state = .authenticated(AuthenticatedAppContainer(userId: userId))
                    } else {
                        state = .unauthenticated(UnauthenticatedAppContainer())
                    }
                }
            }
        }
    }

    private func validateUserProfile(userId: String) async -> Bool {
        for _ in 0..<9 {
            do {
                _ = try await getUser.byId(with: userId)
                return true
            } catch FirestoreClientError.documentNotFound {
                try? await Task.sleep(nanoseconds: 200_000_000)
            } catch {
                signOutInvalidSession()
                return false
            }
        }

        do {
            _ = try await getUser.byId(with: userId)
            return true
        } catch {
            signOutInvalidSession()
            return false
        }
    }

    private func signOutInvalidSession() {
        do { try signOut.execute() }
        catch { print("Failed to sign out invalid session: \(error.localizedDescription)") }
    }
}
