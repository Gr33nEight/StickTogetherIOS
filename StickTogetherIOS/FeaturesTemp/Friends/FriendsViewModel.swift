//
//  FriendsViewModelTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

@MainActor
final class FriendsViewModel: ObservableObject {
    @Published var pickedFriendsListType: FriendsListType = .allFriends
    @Published var event: FriendsViewEvent?
    
    @Published private(set) var visibleFriends: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var friendRequestNotifications = [Notification]()
    
    @Published private var receivedInvitations: [InvitationWithUser] = []
    @Published private var sentInvitations: [InvitationWithUser] = []
    
    private var friendsTask: Task<Void, Never>?
    private var receivedInvitationsTask: Task<Void, Never>?
    private var sentInvitationsTask: Task<Void, Never>?
    
    private let currentUserId: String
    private let listenToFriends: ListenToFriendsUseCase
    private let listenToReceivedInvitations: ListenToInvitations
    private let listenToSentInvitations: ListenToInvitations
    private let getUser: GetUserUseCase
    private let sendInvitation: SendInvitationUseCase
    private let acceptInvitation: AcceptInvitationUseCase
    private let removeInvitation: RemoveInvitationUseCase
    private let declineInvitation: DeclineInvitationUseCase
    private let removeFriend: RemoveFriendUseCase
    
    var visibleInvitations: [InvitationWithUser] {
        switch pickedFriendsListType {
        case .invitationReceived:
            return receivedInvitations
        case .invitationSent:
            return sentInvitations
        case .allFriends:
            return []
        }
    }
    
    var numberOfReceivedInvitations: Int {
        receivedInvitations.count
    }
    
    init(
        currentUserId: String,
        listenToFriends: ListenToFriendsUseCase,
        listenToReceivedInvitations: ListenToInvitations,
        listenToSentInvitations: ListenToInvitations,
        getUser: GetUserUseCase,
        sendInvitation: SendInvitationUseCase,
        acceptInvitation: AcceptInvitationUseCase,
        removeInvitation: RemoveInvitationUseCase,
        declineInvitation: DeclineInvitationUseCase,
        removeFriend: RemoveFriendUseCase
    ) {
        self.currentUserId = currentUserId
        self.listenToFriends = listenToFriends
        self.listenToReceivedInvitations = listenToReceivedInvitations
        self.listenToSentInvitations = listenToSentInvitations
        self.getUser = getUser
        self.sendInvitation = sendInvitation
        self.acceptInvitation = acceptInvitation
        self.removeInvitation = removeInvitation
        self.declineInvitation = declineInvitation
        self.removeFriend = removeFriend
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
    
    func handleInviteTap(
        invitedBuddy: User?,
        fullList: Bool,
        onDismiss: ((User) -> Void)?
    ) {
        if let buddy = invitedBuddy,
           let onDismiss = onDismiss {
            onDismiss(buddy)
            event = .dimsiss
            return
        }
        
        if invitedBuddy == nil || fullList {
            event = .showInviteModal
        }
        
    }
    
    func handleInvite(to userEmail: String) async {
        if visibleFriends.contains(where: {$0.email == userEmail}) {
            event = .showToastMessage(.info("This user is already your friend!"))
            return
        }
        do {
            try await sendInvitation.execute(from: currentUserId, to: userEmail)
            // sendNotification
            event = .closeModal
        } catch let error as InvitationError {
            handleInvitationError(error)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func acceptInvitation(with invitationId: String) async {
        do {
            try await acceptInvitation.execute(invitationId: invitationId)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }

    func removeInvitation(with invitationId: String) async {
        do {
            try await removeInvitation.execute(invitationId: invitationId)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func declineInvitation(with invitationId: String) async {
        do {
            try await declineInvitation.execute(invitationId: invitationId)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func removeFriend(by userId: String) async {
        do {
            try await removeFriend.execute(userId: currentUserId, friendId: userId)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    private func handleInvitationError(_ error: InvitationError) {
        switch error {
        case .userNotFound:
            event = .showToastMessage(.failed("Couldn't find user"))
        case .cannotInviteYourself:
            event = .showToastMessage(.info("You can't invite yourself"))
        case .invitationAlreadySent:
            event = .showToastMessage(.failed("Invitation already sent"))
        case .invitationAlreadyReceived:
            event = .showToastMessage(.failed("Invitation already received"))
        }
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
                event = .showToastMessage(.failed("Failed to fetch friends."))
            }
        }
    }
    
    private func stopListeningToSentInvitations() {
        sentInvitationsTask?.cancel()
        sentInvitationsTask = nil
    }
    
    private func startListeningToSentInvitations(){
        stopListeningToSentInvitations()
        isLoading = true
        defer { isLoading = false }
        
        sentInvitationsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToSentInvitations.stream(for: currentUserId)
                for try await invitations in stream {
                    self.sentInvitations = invitations
                }
            } catch {
                event = .showToastMessage(.failed("Failed to fetch sent invitations."))
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
                }
            } catch {
                event = .showToastMessage(.failed("Failed to fetch received invitations."))
            }
        }
    }
    
    deinit {
        print("FriendsViewModel deinited")
        friendsTask?.cancel()
        receivedInvitationsTask?.cancel()
        sentInvitationsTask?.cancel()
    }
}
