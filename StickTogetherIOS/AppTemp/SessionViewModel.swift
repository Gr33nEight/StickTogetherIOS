//
//  SessionViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    
    enum SessionState {
        case loading
        case authenticated(AuthenticatedAppContainer)
        case unauthenticated(UnauthenticatedAppContainer)
    }
    
    @Published private(set) var state: SessionState = .loading
    
    private let observeSession: ObserveSessionUseCase
    private var task: Task<Void, Never>?
    
    init(observeSession: ObserveSessionUseCase) {
        self.observeSession = observeSession
        
        start()
    }
    
    deinit {
        task?.cancel()
    }
    
    private func start() {
        task = Task {
            for await session in observeSession.stream() {
                print(session)
                switch session {
                case .loggedOut:
                    state = .unauthenticated(UnauthenticatedAppContainer())
                case .loggedIn(let userId):
                    state = .authenticated(AuthenticatedAppContainer(userId: userId))
                }
            }
        }
    }
}
