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
    
    init(authService: AuthServiceProtocol = FirebaseAuthService(), habitService: HabitServiceProtocol = FirebaseHabitService()) {
        self.authService = authService
        self.habitService = habitService
    }
}
