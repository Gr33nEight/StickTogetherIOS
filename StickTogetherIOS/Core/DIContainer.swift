//
//  DIContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import Foundation

final class DIContainer: ObservableObject {
    let authService: AuthServiceProtocol
    let habitService: HabitServiceProtocol
    let friendsService: FriendsServiceProtocol
    
    init(
        authService: AuthServiceProtocol = FirebaseAuthService(),
        habitService: HabitServiceProtocol = FirebaseHabitService(),
        friendsService: FriendsServiceProtocol = FirebaseFriendsService()
    ) {
        self.authService = authService
        self.habitService = habitService
        self.friendsService = friendsService
    }
}
