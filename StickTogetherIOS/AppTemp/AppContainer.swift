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
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(currentUserId: userId, listenToOwnedHabits: listenToOwnedHabits, listenToBuddyHabits: listenToBuddyHabits, listenToSharedHabits: listenToSharedHabits)
    }
    
    @MainActor
    func makeHomeView() -> some View {
        HomeViewTemp(viewModel: self.makeHomeViewModel())
    }
}
