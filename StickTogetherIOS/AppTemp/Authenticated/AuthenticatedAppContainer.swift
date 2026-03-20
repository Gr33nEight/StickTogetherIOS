//
//  AppContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import SwiftUI

final class AuthenticatedAppContainer {

    // MARK: - Input

    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Clients

    private lazy var firestoreClient: FirestoreClient = FirestoreClientImpl()
    private lazy var firestoreTransactionClient: FirestoreTransactionClient = FirestoreTransactionClientImpl()
    private lazy var authClient: AuthClient = AuthClientImpl()

    // MARK: - Factories / Runners

    private lazy var transactionFactory: TransactionFactory =
        FirestoreTransactionFactory(client: firestoreClient)

    // MARK: - Repositories

    private lazy var habitRepository: HabitRepository =
        HabitRepositoryImpl(firestoreClient: firestoreClient)

    private lazy var friendsRepository: FriendsRepository =
        FriendsRepositoryImpl(
            firestoreClient: firestoreClient,
            firestoreTransactionClient: firestoreTransactionClient
        )

    private lazy var userRepository: UserRepository =
        UserRepositoryImpl(firestoreClient: firestoreClient)

    private lazy var invitationsRepository: InvitationsRepository =
        InvitationsRepositoryImpl(
            firestoreClient: firestoreClient,
            firestoreTransactionClient: firestoreTransactionClient
        )

    private lazy var authRepository: AuthRepository =
        AuthRepositoryImpl(
            authClient: authClient,
            firestoreClient: firestoreClient
        )

    private lazy var notificationsRepository: NotificationsRepository =
        NotificationsRepositoryImpl()

    // MARK: - UseCases (Auth)

    private lazy var signOut: SignOutUseCase =
        SignOutUseCaseImpl(repository: authRepository)

    // MARK: - UseCases (Habits)

    private lazy var listenToOwnedHabits: ListenToHabitsUseCase =
        ListenToOwnedHabitsUseCase(repository: habitRepository)

    private lazy var listenToBuddyHabits: ListenToHabitsUseCase =
        ListenToBuddyHabitsUseCase(repository: habitRepository)

    private lazy var listenToSharedHabits: ListenToHabitsUseCase =
        ListenToSharedHabitsUseCase(repository: habitRepository)

    // MARK: - UseCases (Friends & Invitations)

    private lazy var listenToFriends: ListenToFriendsUseCase =
        ListenToFriendsUseCaseImpl(repository: userRepository)

    private lazy var listenToReceivedInvitations: ListenToInvitations =
        ListenToReceivedInvitationsUseCase(
            repository: invitationsRepository,
            userRepository: userRepository
        )

    private lazy var listenToSentInvitations: ListenToInvitations =
        ListenToSentInvitationsUseCase(
            repository: invitationsRepository,
            userRepository: userRepository
        )

    private lazy var sendInvitation: SendInvitationUseCase =
        SendInvitationUseCaseImpl(
            invitationsRepository: invitationsRepository,
            userReporitory: userRepository
        )

    private lazy var acceptInvitation: AcceptInvitationUseCase =
        AcceptInvitationUseCaseImpl(
            transactionFactory: transactionFactory,
            invitationsRepository: invitationsRepository,
            friendsRepository: friendsRepository
        )

    private lazy var removeInvitation: RemoveInvitationUseCase =
        RemoveInvitationUseCaseImpl(
            invitationsRepository: invitationsRepository
        )

    private lazy var removeFriend: RemoveFriendUseCase =
        RemoveFriendUseCaseImpl(
            transactionFactory: transactionFactory,
            friendsRepository: friendsRepository
        )

    // MARK: - UseCases (User)

    private lazy var getUser: GetUserUseCase =
        GetUserUseCaseImpl(userRepository: userRepository)

    private lazy var listenToUser: ListenToUserUseCase =
        ListenToUserUseCaseImpl(repository: userRepository)

    // MARK: - UseCases (Notifications)

    private lazy var sendNotification: SendNotificationUseCase =
        SendNotificationUseCaseImpl(
            notificationsRepository: notificationsRepository
        )

    // MARK: - ViewModels

    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            currentUserId: userId,
            listenToOwnedHabits: listenToOwnedHabits,
            listenToBuddyHabits: listenToBuddyHabits,
            listenToSharedHabits: listenToSharedHabits
        )
    }
    
    @MainActor
    private func makeFriendsViewModel() -> FriendsViewModelTemp {
        FriendsViewModelTemp(
            currentUserId: userId,
            listenToFriends: listenToFriends,
            listenToReceivedInvitations: listenToReceivedInvitations,
            listenToSentInvitations: listenToSentInvitations,
            getUser: getUser,
            sendInvitation: sendInvitation,
            acceptInvitation: acceptInvitation,
            removeInvitation: removeInvitation,
            removeFriend: removeFriend,
            sendNotification: sendNotification
        )
    }
    
    @MainActor
    private func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            currentUserId: userId,
            signOut: signOut,
            listenToUser: listenToUser
        )
    }

    // MARK: - Views

    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
    
    @MainActor
    func makeFriendsView() -> some View {
        FriendsListView(
            fullList: true,
            viewModel: self.makeFriendsViewModel()
        )
    }
    
    @MainActor
    func makeSettingsView() -> some View {
        SettingsView(viewModel: self.makeSettingsViewModel())
    }
}
