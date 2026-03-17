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
//    private let listenToFriends:
    private let listenToReceivedInvitations: ListenToInvitations
    private let listenToSentInvitations: ListenToInvitations
    
    init(
        currentUserId: String,
        listenToReceivedInvitations: ListenToInvitations,
        listenToSentInvitations: ListenToInvitations
    ) {
        self.currentUserId = currentUserId
        self.listenToReceivedInvitations = listenToReceivedInvitations
        self.listenToSentInvitations = listenToSentInvitations
    }
    
    func startListening() {
        stopListening()
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
    
    func stopListening() {
        receivedInvitationsTask?.cancel()
        sentInvitationsTask?.cancel()
        
        receivedInvitationsTask = nil
        sentInvitationsTask = nil
    }
    
    private func updateVisibleInvitationType() {
        switch pickedFriendsListType {
        case .allFriends:
            self.visibleInvitationType = []
        case .invitationReceived:
            self.visibleInvitationType = receivedInvitations
        case .invitationSent:
            self.visibleInvitationType = sentInvitations
        }
    }
}
