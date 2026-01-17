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
    
    private let profileService: any ProfileServiceProtocol
    private let friendsService: FriendsServiceProtocol

    // Firestore listener registrations
    private var sentListener: ListenerRegistration?
    private var receivedListener: ListenerRegistration?
    private let firestore = Firestore.firestore()
    
    // ensure loader shown only for the very first fetch
    private var didInitialLoad: Bool = false
    
    // Add these properties near the top of FriendsViewModel:
    private var userDocListener: ListenerRegistration?
    private let currentUserId: String
    
    init(profileService: any ProfileServiceProtocol,
         friendsService: FriendsServiceProtocol,
         loading: LoadingManager? = nil,
         currentUserId: String) {
        self.friendsService = friendsService
        self.profileService = profileService
        self.currentUserId = currentUserId
    }
    
    static func configured(profileService: ProfileServiceProtocol,
                              friendsService: FriendsServiceProtocol,
                              currentUserId: String) -> FriendsViewModel {
           return FriendsViewModel(profileService: profileService,
                                   friendsService: friendsService,
                                   currentUserId: currentUserId)
       }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.stopInvitationListeners()
        }
    }

    // MARK: - Listeners
    func startInvitationListeners() async {
        stopInvitationListeners()
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
            return try await profileService.getUserById(id)
        } catch {
            print("Failed to load friend: \(error)")
            return nil
        }
    }

    // Utility: chunking helper
    private func chunked<T>(_ array: [T], chunkSize: Int) -> [[T]] {
        guard chunkSize > 0 else { return [array] }
        var result: [[T]] = []
        var i = 0
        while i < array.count {
            let end = Swift.min(i + chunkSize, array.count)
            result.append(Array(array[i..<end]))
            i += chunkSize
        }
        return result
    }

    // MARK: - Friends listener (listen to current user's document for friendsIds changes)
    func startFriendsListener() async {
        // stop existing to avoid duplicates
        stopFriendsListener()
        userDocListener = firestore.collection("users").document(currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot, snapshot.exists else { return }

                // read friendsIds from snapshot safely
                if let data = snapshot.data(), let raw = data["friendsIds"] as? [String] {
                    Task { @MainActor in
                        await self.loadFriendsFromIds(raw, preferLoader: false)
                        print("Friends: \(self.friends.map{ $0.name})")
                    }
                } else {
                    // no friends yet
                    Task { @MainActor in
                        self.friends = []
                    }
                }
            }
    }

    @MainActor
    func stopFriendsListener() {
        userDocListener?.remove()
        userDocListener = nil
    }

    // Helper: load friends by ids with chunking (uses authService.getUsersByIds)
    private func loadFriendsFromIds(_ ids: [String], preferLoader: Bool = false) async {
        // quick exit
        if ids.isEmpty {
            self.friends = []
            return
        }

        // Firestore 'in' supports up to 10 items; chunk the ids
        let chunks = chunked(ids, chunkSize: 10)
        var aggregated: [User] = []

        await withTaskGroup(of: [User].self) { group in
            for chunk in chunks {
                group.addTask { [profileService] in
                    do {
                        return try await profileService.getUsersByIds(chunk)
                    } catch {
                        print("Failed fetching friend chunk: \(error)")
                        return []
                    }
                }
            }

            for await sub in group {
                aggregated.append(contentsOf: sub)
            }
        }

        // preserve ordering from ids (optional)
        let byId = Dictionary(uniqueKeysWithValues: aggregated.map { ($0.id ?? UUID().uuidString, $0) })
        let ordered = ids.compactMap { byId[$0] }
        self.friends = ordered
    }
    
    func fetchFriendByEmail(_ email: String) async -> User? {
        do {
            return try await profileService.getUserByEmail(email.lowercased())
        } catch {
            print("Failed to load friend: \(error)")
            return nil
        }
    }
    
    func sendInvitation(to userEmail: String) async -> SuccessOrError {
        let senderUserId = currentUserId
        guard let receiverUserId = await self.fetchFriendByEmail(userEmail)?.id else {
            return .error("Couldn't find user with this email.")
        }
        if invitationSent.contains(where: { $0.senderId == senderUserId && $0.receiverId == receiverUserId }) { return .error("You already sent an invitation to this user.") }
        if invitationReceived.contains(where: { $0.senderId == receiverUserId && $0.receiverId == senderUserId}) { return .error("This user already sent you an invitation.") }
        
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
                        group.addTask { [profileService] in
                            do {
                                let user = try await profileService.getUserById(userId)
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
            friendsFromInvitation = try await load()
            return .success
        } catch {
            print("Failed to load friendsFromInvitation: \(error)")
            return .error(error.localizedDescription)
        }
    }
    
    private func fetchReceivedInvitation(useLoader: Bool = false) async -> SuccessOrError {
        do {
            invitationReceived = try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: false)
            return .success
        } catch {
            return .error("Couldn't fetch received invitations: \(error)")
        }
    }
    
    private func fetchSentInvitation(useLoader: Bool = false) async -> SuccessOrError {
        do {
            invitationSent = try await self.friendsService.fetchAllUsersInvitation(for: currentUserId, sent: true)
            return .success
        } catch {
            return .error("Couldn't fetch sent invitations: \(error)")
        }
    }
    
    
    func acceptInvitation(invitation: Invitation) async -> SuccessOrError {
        guard let invitationId = invitation.id else {
            return .error("Couldn't get invitation id")
        }
        do {
            try await self.friendsService.addToFriendsList(friendId: invitation.senderId, for: currentUserId)
            try await self.friendsService.addToFriendsList(friendId: currentUserId, for: invitation.senderId)
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
    
    func removeFromFriendsList(userId: String) async -> SuccessOrError {
        do {
            try await self.friendsService.removeFromFriendsList(friendId: userId, for: currentUserId)
            try await self.friendsService.removeFromFriendsList(friendId: currentUserId, for: userId)
            return .success
        } catch {
            return .error("Couldn't remove from friends list: \(error)")
        }
    }
}
