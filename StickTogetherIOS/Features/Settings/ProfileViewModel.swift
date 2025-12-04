//
//  ProfileViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 22/11/2025.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    
    private let profileService: any ProfileServiceProtocol
    private var streamTask: Task<Void, Never>?
    
    var safeUser: User {
        currentUser ?? User(name: "", email: "")
    }
    
    init(profileService: any ProfileServiceProtocol) {
        self.profileService = profileService
        subscribe()
    }
    
    deinit {
        streamTask?.cancel()
    }
    
    private func subscribe() {
        streamTask?.cancel()
        streamTask = Task { [weak self] in
            guard let self = self else { return }
            for await user in self.profileService.authStateStream() {
                await MainActor.run {
                    self.currentUser = user
                }
            }
        }
    }
    
    func updateUser(_ user: User) async -> SuccessOrError {
        do {
            try await profileService.updateUser(user)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func updateUserProfileIcon(_ icon: String) async -> SuccessOrError {
        do {
            try await profileService.updateUserProfileIcon(icon, forUserId: currentUser?.id)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
