//
//  DIContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import Foundation

final class DIContainer: ObservableObject {
    let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
    }
}
