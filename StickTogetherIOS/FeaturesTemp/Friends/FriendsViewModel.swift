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
    @Published private(set) var friendRequestNotifications = [Notification]()
    
    @Published private var receivedInvitations: [InvitationWithUser] = []
    @Published private var sentInvitations: [InvitationWithUser] = []
    
    private var friendsTask: Task<Void, Never>?
    private var receivedInvitationsTask: Task<Void, Never>?
    private var sentInvitationsTask: Task<Void, Never>?
    private let loadingManager = LoadingManager.shared
    private var listenerGeneration = 0
    private var initialLoadTokens: [String: UUID] = [:]
    private var hasCompletedInitialLoad = false
    
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
        stopListening()
        if !hasCompletedInitialLoad {
            initialLoadTokens = [
                "friends": loadingManager.begin(),
                "sentInvitations": loadingManager.begin(),
                "receivedInvitations": loadingManager.begin()
            ]
        }
        let generation = listenerGeneration
        startListeningToFriends(generation: generation)
        startListeningToSentInvitations(generation: generation)
        startListeningToReceivedInvitations(generation: generation)
    }
    
    func stopListening() {
        listenerGeneration += 1
        stopListeningToFriends()
        stopListeningToSentInvitations()
        stopListeningToReceivedInvitations()
        for token in initialLoadTokens.values {
            loadingManager.finish(token)
        }
        initialLoadTokens.removeAll()
    }

    private func finishInitialLoad(_ key: String, generation: Int) {
        guard generation == listenerGeneration,
              let token = initialLoadTokens.removeValue(forKey: key) else { return }
        loadingManager.finish(token)
        if initialLoadTokens.isEmpty {
            hasCompletedInitialLoad = true
        }
    }
    
    func handleInviteTap() { event = .showInviteModal }
    
    func handleInvite(to userEmail: String) async {
        if visibleFriends.contains(where: {$0.email == userEmail}) {
            event = .showToastMessage(.info("This user is already your friend!"))
            return
        }
        do {
            try await loadingManager.run {
                try await sendInvitation.execute(from: currentUserId, to: userEmail)
            }
            event = .closeModal
        } catch let error as InvitationError {
            handleInvitationError(error)
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func acceptInvitation(with invitationId: String) async {
        do {
            try await loadingManager.run {
                try await acceptInvitation.execute(invitationId: invitationId)
            }
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }

    func removeInvitation(with invitationId: String) async {
        do {
            try await loadingManager.run {
                try await removeInvitation.execute(invitationId: invitationId)
            }
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func declineInvitation(with invitationId: String) async {
        do {
            try await loadingManager.run {
                try await declineInvitation.execute(invitationId: invitationId)
            }
        } catch {
            event = .showToastMessage(.failed("Something went wrong"))
        }
    }
    
    func removeFriend(by userId: String) async {
        do {
            try await loadingManager.run {
                try await removeFriend.execute(userId: currentUserId, friendId: userId)
            }
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
    
    private func startListeningToFriends(generation: Int) {
        friendsTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = listenToFriends.stream(for: currentUserId)
                for try await friends in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.visibleFriends = friends
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("friends", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("friends", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                event = .showToastMessage(.failed("Failed to fetch friends."))
            }
            finishInitialLoad("friends", generation: generation)
        }
    }
    
    private func stopListeningToSentInvitations() {
        sentInvitationsTask?.cancel()
        sentInvitationsTask = nil
    }
    
    private func startListeningToSentInvitations(generation: Int) {
        sentInvitationsTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = listenToSentInvitations.stream(for: currentUserId)
                for try await invitations in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.sentInvitations = invitations
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("sentInvitations", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("sentInvitations", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                event = .showToastMessage(.failed("Failed to fetch sent invitations."))
            }
            finishInitialLoad("sentInvitations", generation: generation)
        }
    }
    
    private func stopListeningToReceivedInvitations() {
        receivedInvitationsTask?.cancel()
        receivedInvitationsTask = nil
    }
    
    private func startListeningToReceivedInvitations(generation: Int) {
        receivedInvitationsTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = listenToReceivedInvitations.stream(for: currentUserId)
                for try await invitations in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.receivedInvitations = invitations
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("receivedInvitations", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("receivedInvitations", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                event = .showToastMessage(.failed("Failed to fetch received invitations."))
            }
            finishInitialLoad("receivedInvitations", generation: generation)
        }
    }
    
    deinit {
        print("FriendsViewModel deinited")
        friendsTask?.cancel()
        receivedInvitationsTask?.cancel()
        sentInvitationsTask?.cancel()
    }
}
