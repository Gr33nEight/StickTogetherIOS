//
//  AppContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import SwiftUI

final class AuthenticatedAppContainer {
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    private lazy var firestoreClient: FirestoreClient = FirestoreClientImpl()
    private lazy var authClient: AuthClient = AuthClientImpl()
    
    private lazy var habitRepository: HabitRepository = HabitRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var friendsRepository: FriendsRepository = FriendsRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var userRepository: UserRepository = UserRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var invitationsRepository: InvitationsRepository = InvitationsRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var authRepository: AuthRepository = AuthRepositoryImpl(authClient: authClient, firestoreClient: firestoreClient)

    private lazy var signOut: SignOutUseCase = SignOutUseCaseImpl(repository: authRepository)
    
    private lazy var listenToOwnedHabits: ListenToHabitsUseCase = ListenToOwnedHabitsUseCase(repository: habitRepository)
    private lazy var listenToBuddyHabits: ListenToHabitsUseCase = ListenToBuddyHabitsUseCase(repository: habitRepository)
    private lazy var listenToSharedHabits: ListenToHabitsUseCase = ListenToSharedHabitsUseCase(repository: habitRepository)
    
    private lazy var listenToFriends: ListenToFriendsUseCase = ListenToFriendsUseCaseImpl(repository: userRepository)
    private lazy var listenToReceivedInvitations: ListenToInvitations = ListenToReceivedInvitationsUseCase(repository: invitationsRepository, userRepository: userRepository)
    private lazy var listenToSentInvitations: ListenToInvitations = ListenToSentInvitationsUseCase(repository: invitationsRepository, userRepository: userRepository)
    private lazy var sendInvitation: SendInvitationUseCase = SendInvitationUseCaseImpl(invitationsRepository: invitationsRepository, userReporitory: userRepository)
    private lazy var acceptInvitation = AcceptInvitationUseCaseImpl(friendsRepository: friendsRepository, invitationsRepository: invitationsRepository)
    private lazy var removeInvitation = RemoveInvitationUseCaseImpl(invitationsRepository: invitationsRepository)
    private lazy var removeFriend = RemoveFriendUseCaseImpl(friendsRepository: friendsRepository)
    
    private lazy var getUser: GetUserUseCase = GetUserUseCaseImpl(userRepository: userRepository)
    private lazy var listenToUser: ListenToUserUseCase = ListenToUserUseCaseImpl(repository: userRepository)
    
    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(currentUserId: userId, listenToOwnedHabits: listenToOwnedHabits, listenToBuddyHabits: listenToBuddyHabits, listenToSharedHabits: listenToSharedHabits)
    }
    
    @MainActor
    private func makeFriendsViewModel() -> FriendsViewModelTemp {
        return FriendsViewModelTemp(currentUserId: userId, listenToFriends: listenToFriends, listenToReceivedInvitations: listenToReceivedInvitations, listenToSentInvitations: listenToSentInvitations, getUser: getUser, sendInvitation: sendInvitation, acceptInvitation: acceptInvitation, removeInvitation: removeInvitation, removeFriend: removeFriend)
    }
    
    @MainActor
    private func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(currentUserId: userId, signOut: signOut, listenToUser: listenToUser)
    }
    
    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
    
    @MainActor
    func makeFriendsView() -> some View {
        FriendsListView(fullList: true, viewModel: self.makeFriendsViewModel())
    }
    
    @MainActor
    func makeSettingsView() -> some View {
        SettingsView(viewModel: self.makeSettingsViewModel())
    }
}
