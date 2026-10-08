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
    @Published private(set) var error: String?
    
    private var listenToCurrentUserTask: Task<Void, Never>?
    private let loadingManager = LoadingManager.shared
    private var initialLoadToken: UUID?
    private var listenerGeneration = 0
    
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
        let generation = listenerGeneration
        if currentUser == nil {
            initialLoadToken = loadingManager.begin()
        }

        listenToCurrentUserTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = listenToCurrentUser.stream(for: currentUserId)
                for try await user in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.currentUser = user
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad(generation: generation)
                    }
                }
            } catch {
                finishInitialLoad(generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                self.error = error.localizedDescription
            }
            finishInitialLoad(generation: generation)
        }
    }

    private func finishInitialLoad(generation: Int) {
        guard generation == listenerGeneration, let token = initialLoadToken else { return }
        initialLoadToken = nil
        loadingManager.finish(token)
    }
    
    func stopListeningToCurrentUser() {
        listenerGeneration += 1
        listenToCurrentUserTask?.cancel()
        listenToCurrentUserTask = nil
        if let initialLoadToken {
            loadingManager.finish(initialLoadToken)
            self.initialLoadToken = nil
        }
    }
}
