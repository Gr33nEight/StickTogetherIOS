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

    private lazy var habitEntryRepository: HabitEntryRepository =
        HabitEntryRepositoryImpl(firestoreClient: firestoreClient)
    
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
        NotificationsRepositoryImpl(firestoreClient: firestoreClient, transactionClient: firestoreTransactionClient)

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
    
    private lazy var createHabit: CreateHabitUseCase =
        CreateHabitUseCaseImpl(
            habitRepository: habitRepository,
            userRepository: userRepository,
            notificationsRepository: notificationsRepository
        )
    
    private lazy var deleteHabit: DeleteHabitUseCase =
        DeleteHabitUseCaseImpl(habitRepository: habitRepository, habitEntryRepository: habitEntryRepository)
    
    private lazy var listenToHabit: ListenToHabitUseCase =
        ListenToHabitUseCaseImpl(habitRepository: habitRepository)

    // MARK: - UseCases (Habit Entries)
    
    private lazy var getHabitEntries: GetHabitEntriesFromDateRangeUseCase =
        GetHabitEntriesFromDateRangeUseCaseImpl(habitEntryRepository: habitEntryRepository)
    
    private lazy var toggleHabitCompletionState: ToggleHabitCompletionStateUseCase =
        ToggleHabitCompletionStateUseCaseImpl(habitEntryRepository: habitEntryRepository, habitRepository: habitRepository)
    
    private lazy var listenToHabitEntries: ListenToHabitEntriesUseCase =
        ListenToHabitEntriesUseCaseImpl(habitEntryRepository: habitEntryRepository)
    
    private lazy var listenToAllHabitEntries: ListenToAllHabitEntriesOnDate =
        ListenToAllHabitEntriesOnDateImpl(habitEntryRepository: habitEntryRepository)
    
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
            userReporitory: userRepository,
            notificationsRepository: notificationsRepository
        )

    private lazy var acceptInvitation: AcceptInvitationUseCase =
        AcceptInvitationUseCaseImpl(
            transactionFactory: transactionFactory,
            invitationsRepository: invitationsRepository,
            friendsRepository: friendsRepository,
            notificationsRepository: notificationsRepository
        )

    private lazy var removeInvitation: RemoveInvitationUseCase =
        RemoveInvitationUseCaseImpl(
            invitationsRepository: invitationsRepository,
            notificationsRepository: notificationsRepository,
            transactionFactory: transactionFactory
        )

    private lazy var declineInvitation: DeclineInvitationUseCase =
        DeclineInvitationUseCaseImpl(
            invitationsRepository: invitationsRepository,
            notificationsRepository: notificationsRepository,
            transactionFactory: transactionFactory
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
    
    private lazy var listenToNotification: ListenToNotificationsUseCase =
        ListenToNotificationsUseCaseImpl(notificationsRepository: notificationsRepository)
    
    private lazy var markAsRead: MarkAsReadUseCase =
        MarkAsReadUseCaseImpl(notificationsRepository: notificationsRepository)
    
    private lazy var encourageBuddies: EncourageBuddiesUseCase =
        EncourageBuddiesUseCaseImpl(notificationsRepository: notificationsRepository, userRepository: userRepository)
    
    // MARK: - ViewModels

    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            currentUserId: userId,
            listenToOwnedHabits: listenToOwnedHabits,
            listenToBuddyHabits: listenToBuddyHabits,
            listenToSharedHabits: listenToSharedHabits,
            getCurrentUser: getUser,
            toggleHabitCompletion: toggleHabitCompletionState,
            listenToAllHabitEntriesOnDate: listenToAllHabitEntries,
            getHabitEntries: getHabitEntries
        )
    }
    
    @MainActor
    private func makeFriendsViewModel() -> FriendsViewModel {
        FriendsViewModel(
            currentUserId: userId,
            listenToFriends: listenToFriends,
            listenToReceivedInvitations: listenToReceivedInvitations,
            listenToSentInvitations: listenToSentInvitations,
            getUser: getUser,
            sendInvitation: sendInvitation,
            acceptInvitation: acceptInvitation,
            removeInvitation: removeInvitation,
            declineInvitation: declineInvitation,
            removeFriend: removeFriend
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
    
    @MainActor
    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(
            currentUserId: userId,
            listenToUserNotifications: listenToNotification,
            markAsReadUseCase: markAsRead
        )
    }
    
    @MainActor
    func makeCreateHabitViewModel() -> CreateHabitViewModel {
        CreateHabitViewModel(
            currentUserId: userId,
            createHabit: createHabit
        )
    }
    
    @MainActor
    func makeFriendsListViewModel() -> FriendsListViewModel {
        FriendsListViewModel(
            currentUserId: userId,
            listenToFriends: listenToFriends,
            sendInvitation: sendInvitation
        )
    }

    @MainActor
    func makeHabitViewModel(_ container: HabitViewContainer) -> HabitViewModel {
        HabitViewModel(
            container: container,
            currentUserId: userId,
            getUserById: getUser,
            deleteHabit: deleteHabit,
            encourageBuddies: encourageBuddies,
            toggleHabitCompletionState: toggleHabitCompletionState,
            listenToHabit: listenToHabit,
            listenToEntries: listenToHabitEntries
        )
    }
    
    // MARK: - Views

    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
        
    @MainActor
    func makeFriendsView() -> some View {
        FriendsView(viewModel: self.makeFriendsViewModel())
    }
    
    @MainActor
    func makeSettingsView() -> some View {
        SettingsView(viewModel: self.makeSettingsViewModel())
    }
    
    @MainActor
    func makeNotificationsView() -> some View {
        NotificationView()
    }
    
    @MainActor
    func makeHabitView(_ container: HabitViewContainer) -> some View {
        HabitView(viewModel: self.makeHabitViewModel(container))
    }
    
    @MainActor
    func makeCreateHabitView() -> some View {
        CreateHabitView(viewModel: self.makeCreateHabitViewModel(), friendsListVM: self.makeFriendsListViewModel())
    }
}
