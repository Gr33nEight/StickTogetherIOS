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
    
    lazy var firestoreClient: FirestoreClient = FirestoreClientImpl()
    
    lazy var habitRepository: HabitRepository = HabitRepositoryImpl(firestoreClient: firestoreClient)
    
    lazy var listenToOwnedHabits: ListenToHabitsUseCase = ListenToOwnedHabitsUseCase(repository: habitRepository)
    lazy var listenToBuddyHabits: ListenToHabitsUseCase = ListenToBuddyHabitsUseCase(repository: habitRepository)
    lazy var listenToSharedHabits: ListenToHabitsUseCase = ListenToSharedHabitsUseCase(repository: habitRepository)
    
    @MainActor
    private func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(currentUserId: userId, listenToOwnedHabits: listenToOwnedHabits, listenToBuddyHabits: listenToBuddyHabits, listenToSharedHabits: listenToSharedHabits)
    }
    
    @MainActor
    private func makeFriendsViewModel() -> FriendsViewModel {
        return FriendsViewModel()
    }
    
    @MainActor
    private func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel()
    }
    
    @MainActor
    private func makeNotificationViewModel() -> NotificationViewModel {
        return NotificationViewModel()
    }
    
    @MainActor
    private func makeCreateHabitViewModel() -> CreateHabitViewModel {
        return CreateHabitViewModel()
    }
    
    @MainActor
    private func makeHabitViewModel() -> HabitViewModel {
        return HabitViewModel()
    }
    
    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
        
    @MainActor
    func makeFriendsView() -> some View {
        FriendsView(viewModel: self.makeFriendsViewModel())
    }
    
    @MainActor
    func makeProfileView() -> some View {
        return ProfileView(viewModel: self.makeProfileViewModel())
    }
    
    @MainActor
    func makeNotificationView() -> some View {
        return NotificationView(viewModel: self.makeNotificationViewModel())
    }
    
    @MainActor
    func makeCreateHabitView() -> some View {
        return CreateHabitView(viewModel: self.makeCreateHabitViewModel())
    }
    
    @MainActor
    func makeHabitView() -> some View {
        return HabitView(viewModel: self.makeHabitViewModel())
    }

}
