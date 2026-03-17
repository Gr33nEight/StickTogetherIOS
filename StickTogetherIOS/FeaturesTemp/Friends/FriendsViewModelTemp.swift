//
//  FriendsViewModelTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

@MainActor
final class FriendsViewModelTemp: ObservableObject {
    @Published var pickedFriendsListType: FriendsListType = .allFriends

    @Published private(set) var visibleFriends: [User] = []
    @Published private(set) var visibleInvitationType: [Invitation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private var receivedInvitations: [Invitation] = []
    private var sentInvitations: [Invitation] = []
    
    private var friendsTask: Task<Void, Never>?
    private var receivedInvitationsTask: Task<Void, Never>?
    private var sentInvitationsTask: Task<Void, Never>?
    
    private let currentUserId: String
    private let listenToFriends: ListenToFriendsUseCase
    private let listenToReceivedInvitations: ListenToInvitations
    private let listenToSentInvitations: ListenToInvitations
    
    init(
        currentUserId: String,
        listenToFriends: ListenToFriendsUseCase,
        listenToReceivedInvitations: ListenToInvitations,
        listenToSentInvitations: ListenToInvitations
    ) {
        self.currentUserId = currentUserId
        self.listenToFriends = listenToFriends
        self.listenToReceivedInvitations = listenToReceivedInvitations
        self.listenToSentInvitations = listenToSentInvitations
    }
    
    func startListening() {
        startListeningToFriends()
        startListeningToSentInvitations()
        startListeningToReceivedInvitations()
    }
    
    func stopListening() {
        stopListeningToFriends()
        stopListeningToSentInvitations()
        stopListeningToReceivedInvitations()
    }
    
    private func stopListeningToFriends() {
        friendsTask?.cancel()
        friendsTask = nil
    }
    
    private func startListeningToFriends() {
        isLoading = true
        defer { isLoading = false }
        stopListeningToFriends()
        
        friendsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToFriends.stream(for: currentUserId)
                for try await friends in stream {
                    self.visibleFriends = friends
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func stopListeningToSentInvitations() {
        sentInvitationsTask?.cancel()
        sentInvitationsTask = nil
    }
    
    private func startListeningToSentInvitations(){
        isLoading = true
        defer { isLoading = false }
        
        stopListeningToSentInvitations()
        
        sentInvitationsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToSentInvitations.stream(for: currentUserId)
                for try await invitations in stream {
                    self.sentInvitations = invitations
                    self.updateVisibleInvitationType()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func stopListeningToReceivedInvitations() {
        receivedInvitationsTask?.cancel()
        receivedInvitationsTask = nil
    }
    
    private func startListeningToReceivedInvitations(){
        stopListeningToReceivedInvitations()
        
        isLoading = true
        defer { isLoading = false }
        
        receivedInvitationsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToReceivedInvitations.stream(for: currentUserId)
                for try await invitations in stream {
                    self.receivedInvitations = invitations
                    self.updateVisibleInvitationType()
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func updateVisibleInvitationType() {
        switch pickedFriendsListType {
        case .allFriends:
            visibleInvitationType = []
        case .invitationReceived:
            visibleInvitationType = receivedInvitations
        case .invitationSent:
            visibleInvitationType = sentInvitations
        }
    }
    
    deinit {
        friendsTask?.cancel()
        receivedInvitationsTask?.cancel()
        sentInvitationsTask?.cancel()
    }
}
