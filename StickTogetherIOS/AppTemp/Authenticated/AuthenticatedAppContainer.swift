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
    
    private lazy var habitRepository: HabitRepository = HabitRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var friendsRepository: FriendsRepository = FriendsRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var userRepository: UserRepository = UserRepositoryImpl(firestoreClient: firestoreClient)
    private lazy var invitationsRepository: InvitationsRepository = InvitationsRepositoryImpl(firestoreClient: firestoreClient)

    private lazy var listenToOwnedHabits: ListenToHabitsUseCase = ListenToOwnedHabitsUseCase(repository: habitRepository)
    private lazy var listenToBuddyHabits: ListenToHabitsUseCase = ListenToBuddyHabitsUseCase(repository: habitRepository)
    private lazy var listenToSharedHabits: ListenToHabitsUseCase = ListenToSharedHabitsUseCase(repository: habitRepository)
    
    private lazy var listenToFriends: ListenToFriendsUseCase = ListenToFriendsUseCaseImpl(repository: userRepository)
    private lazy var listenToReceivedInvitations: ListenToInvitations = ListenToReceivedInvitationsUseCase(repository: invitationsRepository)
    private lazy var listenToSentInvitations: ListenToInvitations = ListenToSentInvitationsUseCase(repository: invitationsRepository)
    
    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(currentUserId: userId, listenToOwnedHabits: listenToOwnedHabits, listenToBuddyHabits: listenToBuddyHabits, listenToSharedHabits: listenToSharedHabits)
    }
    
    @MainActor
    private func makeFriendsViewModel() -> FriendsViewModelTemp {
        return FriendsViewModelTemp(currentUserId: userId, listenToFriends: listenToFriends, listenToReceivedInvitations: listenToReceivedInvitations, listenToSentInvitations: listenToSentInvitations)
    }
    
//    @MainActor
//    private func makeProfileViewModel() -> ProfileViewModel {
//        return ProfileViewModel()
//    }
//    
//    @MainActor
//    private func makeNotificationViewModel() -> NotificationViewModel {
//        return NotificationViewModel()
//    }
//    
//    @MainActor
//    private func makeCreateHabitViewModel() -> CreateHabitViewModel {
//        return CreateHabitViewModel()
//    }
//    
//    @MainActor
//    private func makeHabitViewModel() -> HabitViewModel {
//        return HabitViewModel()
//    }
//    
    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
//        
    @MainActor
    func makeFriendsView() -> some View {
        FriendsListView(viewModel: self.makeFriendsViewModel())
    }
    
    @MainActor
    func makeSettingsView() -> some View {
        SettingsView()
    }
//
//    @MainActor
//    func makeProfileView() -> some View {
//        return ProfileView(viewModel: self.makeProfileViewModel())
//    }
//    
//    @MainActor
//    func makeNotificationView() -> some View {
//        return NotificationView(viewModel: self.makeNotificationViewModel())
//    }
//    
//    @MainActor
//    func makeCreateHabitView() -> some View {
//        return CreateHabitView(viewModel: self.makeCreateHabitViewModel())
//    }
//    
//    @MainActor
//    func makeHabitView() -> some View {
//        return HabitView(viewModel: self.makeHabitViewModel())
//    }

}
