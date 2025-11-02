//
//  UserViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/11/2025.
//

import SwiftUI
import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    @Published private(set) var currentUser: User?
    
    private let authService: any AuthServiceProtocol
    private let loading: LoadingManager?
    private let toast: ToastMessageService?
    
    init(authService: any AuthServiceProtocol, loading: LoadingManager? = nil, toast: ToastMessageService? = nil) {
        self.authService = authService
        self.loading = loading
        self.toast = toast
    }
    
    func loadCurrentUser() async {
        if let loader = loading {
            await loader.run { [self] in
                self.currentUser = await authService.currentUser()
            }
        } else {
            self.currentUser = await authService.currentUser()
        }
    }
    
    func addHabitId(_ habitId: String) async throws {
        guard var user = currentUser else { throw UserError.noCurrentUser }
        if user.habitsIds.contains(habitId) { return }
        user.habitsIds.append(habitId)
        
        try await updateUserOnServer(user)
        currentUser = user
    }
    
    func removeHabitId(_ habitId: String) async throws {
        guard var user = currentUser else { throw UserError.noCurrentUser }
        user.habitsIds.removeAll { $0 == habitId }
        
        try await updateUserOnServer(user)
        currentUser = user
    }
    
    func acceptInvitation(habitId: String) async throws {
        try await addHabitId(habitId)
    }
    
    func leaveSharedHabit(habitId: String) async throws {
        try await removeHabitId(habitId)
    }
    
    private func updateUserOnServer(_ user: User) async throws {
        if let loader = loading {
            try await loader.run { [self] in
                try await authService.updateUser(user)
            }
        } else {
            try await authService.updateUser(user)
        }
    }
}

enum UserError: Error {
    case noCurrentUser
}
