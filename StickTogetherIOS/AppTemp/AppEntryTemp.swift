//
//  AppEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct AppEntryTemp: View {
    @StateObject var viewModel: SessionViewModel
    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .authenticated(let authenticatedAppContainer):
            AuthenticatedRootView(container: authenticatedAppContainer)
        case .unauthenticated(let unauthenticatedAppContainer):
            UnauthenticatedRootView(container: unauthenticatedAppContainer)
        }
    }
}
