//
//  FriendsListViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

@MainActor
final class FriendsListViewModel: ObservableObject {
    
    @Published private(set) var friends: [User] = []
    @Published private(set) var error: String?
    @Published var event: FriendsViewEvent?
    @Published var invitedBuddy: User?
    
    private let currentUserId: String
    private let listenToFriends: ListenToFriendsUseCase
    private let sendInvitation: SendInvitationUseCase
    
    private var friendsTask: Task<Void, Never>?
    
    init(
        currentUserId: String,
        listenToFriends: ListenToFriendsUseCase,
        sendInvitation: SendInvitationUseCase
    ) {
        self.currentUserId = currentUserId
        self.listenToFriends = listenToFriends
        self.sendInvitation = sendInvitation
    }
    
    func startListening() async {
        stopListening()
        friendsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = listenToFriends.stream(for: currentUserId)
                for try await friends in stream {
                    self.friends = friends
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func handleInviteTap(onDismiss: (User) -> Void) {
        if let buddy = invitedBuddy {
            onDismiss(buddy)
            event = .dimsiss
            return
        }
        
        if invitedBuddy == nil {
            event = .showInviteModal
        }
    }
    
    func handleInvite(to userEmail: String) async {
        if friends.contains(where: {$0.email == userEmail}) {
            event = .showToastMessage(.info("This user is already your friend!"))
            return
        }
        do {
            try await sendInvitation.execute(from: currentUserId, to: userEmail)
            event = .closeModal
        } catch let error as InvitationError {
            handleInvitationError(error)
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
    
    
    private func stopListening() {
        friendsTask?.cancel()
        friendsTask = nil
    }
    
    deinit {
        friendsTask = nil
    }
}
