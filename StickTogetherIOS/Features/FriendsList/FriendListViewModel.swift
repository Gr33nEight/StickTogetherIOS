//
//  FriendsListViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class FriendsViewModel: ObservableObject {
    @Published private(set) var friends = [User]()
    @Published private(set) var friendsFromInvitation: [FriendsListType : [String : User]] = [:]
    @Published private(set) var invitationSent = [Invitation]()
    @Published private(set) var invitationReceived = [Invitation]()
    
    private let authService: any AuthServiceProtocol
    private let friendsService: FriendsServiceProtocol
    private var loadingManager: LoadingManager?

    // Firestore listener registrations
    private var sentListener: ListenerRegistration?
    private var receivedListener: ListenerRegistration?
    private let firestore = Firestore.firestore()
    
    // ensure loader shown only for the very first fetch
    private var didInitialLoad: Bool = false
    
    init(authService: any AuthServiceProtocol,
         friendsService: FriendsServiceProtocol,
         loading: LoadingManager? = nil) {
        self.friendsService = friendsService
        self.authService = authService
        self.loadingManager = loading
    }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.stopInvitationListeners()
        }
    }

    // MARK: - Listeners
    func startInvitationListeners() async {
        stopInvitationListeners()
        guard let currentUserId = await authService.currentUser()?.id else { return }

        receivedListener = firestore.collection("invitations")
            .whereField("receiverId", isEqualTo: currentUserId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let snapshot = snapshot else { return }
                let invitations: [Invitation] = snapshot.documents.compactMap { try? $0.data(as: Invitation.self) }
                Task { [weak self] in
                    guard let self = self else { return }
                    await MainActor.run {
                        self.invitationReceived = invitations
                    }
                    _ = await self.fetchAllFriendsFromInvitations(preferLoader: false)
                }
            }

        sentListener = firestore.collection("invitations")
            .whereField("senderId", isEqualTo: currentUserId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let snapshot = snapshot else { return }
                let invitations: [Invitation] = snapshot.documents.compactMap { try? $0.data(as: Invitation.self) }
                Task { [weak self] in
                    guard let self = self else { return }
                    await MainActor.run {
                        self.invitationSent = invitations
                    }
                    _ = await self.fetchAllFriendsFromInvitations(preferLoader: false)
                }
            }
    }

    @MainActor
    func stopInvitationListeners() {
        receivedListener?.remove()
        sentListener?.remove()
        receivedListener = nil
        sentListener = nil
    }
    
    func fetchFriendById(_ id: String) async -> User? {
        do {
            if let loader = loadingManager {
                return try await loader.run { try await self.authService.getUserById(id) }
            } else {
                return try await authService.getUserById(id)
            }
        } catch {
            print("Failed to load friend: \(error)")
            return nil
        }
    }
    
    func fetchFriendsByIds(_ ids: [String]) async {
        do {
            if let loader = loadingManager {
                friends = try await loader.run { try await self.authService.getUsersByIds(ids) }
            } else {
                friends = try await authService.getUsersByIds(ids)
            }
        } catch {
            print("Failed to load friends: \(error)")
        }
    }
    
    private func fetchFriendByEmail(_ email: String) async -> User? {
        do {
            return try await authService.getUserByEmail(email)
        } catch {
            print("Failed to load friend: \(error)")
            return nil
        }
    }
    
    func sendInvitation(to userEmail: String) async -> SuccessOrError {
        guard let senderUserId = await authService.currentUser()?.id else { return .error("Couldn't get current user") }
        guard let receiverUserId = await self.fetchFriendByEmail(userEmail)?.id else {
            return .error("Couldn't find user with this email.")
        }
        if invitationSent.contains(where: { $0.senderId == senderUserId}) { return .error("You already sent an invitation to this user.") }
        if invitationReceived.contains(where: { $0.senderId == receiverUserId}) { return .error("This user already sent you an invitation.") }
        
        do {
            let invitation = Invitation(senderId: senderUserId, receiverId: receiverUserId)
            _ = try await self.friendsService.sendInvitation(invitation)
            return .success
        } catch {
            return .error("Couldn't send invitation: \(error)")
        }
    }
    
    func fetchAllInvitation() async -> SuccessOrError {
        let receivedResult = await self.fetchReceivedInvitation(useLoader: !didInitialLoad)
        let sentResult = await self.fetchSentInvitation(useLoader: !didInitialLoad)
        let allFriendsFromInvitationResult = await self.fetchAllFriendsFromInvitations(preferLoader: !didInitialLoad)
        
        Task { await self.startInvitationListeners() }
        
        if case .error = receivedResult, case .error = sentResult, case .error = allFriendsFromInvitationResult {
            return .error("Couldn't fetch invitations.")
        }
        
        didInitialLoad = true
        return .success
    }

    @MainActor
    func fetchAllFriendsFromInvitations(preferLoader: Bool = false) async -> SuccessOrError {
        let receivedPairs = invitationReceived.compactMap { inv -> (invId: String, userId: String)? in
            guard let id = inv.id else { return nil }
            return (invId: id, userId: inv.senderId)
        }

        let sentPairs = invitationSent.compactMap { inv -> (invId: String, userId: String)? in
            guard let id = inv.id else { return nil }
            return (invId: id, userId: inv.receiverId)
        }
        
        func load() async throws -> [FriendsListType: [String: User]] {
            var receivedDict: [String: User] = [:]
            var sentDict: [String: User] = [:]

            func fetchPairs(_ pairs: [(invId: String, userId: String)]) async -> [String: User] {
                var map: [String: User] = [:]
                if pairs.isEmpty { return map }

                await withTaskGroup(of: (String, User?).self) { group in
                    for (invId, userId) in pairs {
                        group.addTask { [authService] in
                            do {
                                let user = try await authService.getUserById(userId)
                                return (invId, user)
                            } catch {
                                return (invId, nil)
                            }
                        }
                    }

                    for await (invId, maybeUser) in group {
                        if let u = maybeUser {
                            map[invId] = u
                        }
                    }
                }
                return map
            }

            receivedDict = await fetchPairs(receivedPairs)
            sentDict = await fetchPairs(sentPairs)

            return [
                .invitationReceived: receivedDict,
                .invitationSent: sentDict
            ]
        }

        do {
            let loaded: [FriendsListType: [String: User]]
            if preferLoader, let loader = loadingManager {
                loaded = try await loader.run { try await load() }
            } else {
                loaded = try await load()
            }
            friendsFromInvitation = loaded
            return .success
        } catch {
            print("Failed to load friendsFromInvitation: \(error)")
            return .error(error.localizedDescription)
        }
    }
    
    private func fetchReceivedInvitation(useLoader: Bool = false) async -> SuccessOrError {
        guard let currentUserId = await authService.currentUser()?.id else {
            return .error("Couldn't get current user")
        }
        do {
            if useLoader, let loader = loadingManager {
                invitationReceived = try await loader.run { try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: false) }
                return .success
            } else {
                invitationReceived = try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: false)
                return .success
            }
        } catch {
            return .error("Couldn't fetch received invitations: \(error)")
        }
    }
    
    private func fetchSentInvitation(useLoader: Bool = false) async -> SuccessOrError {
        guard let currentUserId = await authService.currentUser()?.id else {
            return .error("Couldn't get current user")
        }
        do {
            if useLoader, let loader = loadingManager {
                invitationSent = try await loader.run { try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: true) }
                return .success
            } else {
                invitationSent = try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: true)
                return .success
            }
        } catch {
            return .error("Couldn't fetch sent invitations: \(error)")
        }
    }
    
    
    func acceptInvitation(invitation: Invitation) async -> SuccessOrError {
        guard let currentUserId = await authService.currentUser()?.id else {
            return .error("Couldn't get current user")
        }
        guard let invitationId = invitation.id else {
            return .error("Couldn't get invitation id")
        }
        do {
            try await self.authService.addToFriendsList(friendId: invitation.senderId, for: currentUserId)
            try await self.authService.addToFriendsList(friendId: currentUserId, for: invitation.senderId)
            try await self.friendsService.deleteInvitation(byId: invitationId)
            return .success
        } catch {
            return .error("Couldn't accept invitation: \(error)")
        }
    }
    
    func declineInvitation(with id: String) async -> SuccessOrError {
        do {
            try await self.friendsService.deleteInvitation(byId: id)
            return .success
        } catch {
            return .error("Couldn't decline invitation: \(error)")
        }
    }
    
    func cancelInvitation(with id: String) async -> SuccessOrError {
        do {
            try await self.friendsService.deleteInvitation(byId: id)
            return .success
        } catch {
            return .error("Couldn't cancel invitation: \(error)")
        }
    }
}
