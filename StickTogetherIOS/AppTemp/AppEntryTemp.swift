//
//  AppEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct AppEntryTemp: View {
    @StateObject var viewModel: SessionViewModel

    @StateObject private var loadingManager = LoadingManager.shared

    var body: some View {
        ZStack {
            Group {
                switch viewModel.state {
                case .loading:
                    LaunchScreenView()
                case .authenticated(let authenticatedAppContainer):
                    AuthenticatedRootView(container: authenticatedAppContainer)
                case .unauthenticated(let unauthenticatedAppContainer):
                    UnauthenticatedRootView(container: unauthenticatedAppContainer)
                }
            }

            if loadingManager.isLoading {
                LoadingOverlay()
                    .zIndex(1)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: loadingManager.isLoading)
    }
}
