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
    
//    @Published private(set) var 
}
