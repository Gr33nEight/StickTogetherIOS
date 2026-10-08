//
//  AuthenticatedRootView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//


import SwiftUI

struct AuthenticatedRootView: View {
    let container: AuthenticatedAppContainer
    
    @StateObject private var notificationsVM: NotificationsViewModel
    
    init(container: AuthenticatedAppContainer) {
        self.container = container
        _notificationsVM = StateObject(
            wrappedValue: container.makeNotificationsViewModel()
        )
    }
    
    var body: some View {
        NavigationStackContentView(authenticatedAppContainer: container)
            .environmentObject(notificationsVM)
            .task {
                notificationsVM.startListeningToUserNotifications()
            }
    }
}
