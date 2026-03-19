//
//  SettingsViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    
    private var listenToCurrentUserTask: Task<Void, Never>?
    
    private let currentUserId: String
    private var signOut: SignOutUseCase
    private var listenToCurrentUser: ListenToUserUseCase
    
    init(
        currentUserId: String,
        signOut: SignOutUseCase,
        listenToUser: ListenToUserUseCase
    ) {
        self.currentUserId = currentUserId
        self.signOut = signOut
        self.listenToCurrentUser = listenToUser
    }
    
    func signOutUser() {
        do {
            currentUser = nil
            try signOut.execute()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func startListeningToCurrentUser() {
        stopListeningToCurrentUser()
        isLoading = true
        defer { isLoading = false }
        
        listenToCurrentUserTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToCurrentUser.stream(for: currentUserId)
                for try await user in stream {
                    self.currentUser = user
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func stopListeningToCurrentUser() {
        listenToCurrentUserTask?.cancel()
        listenToCurrentUserTask = nil
    }
}
