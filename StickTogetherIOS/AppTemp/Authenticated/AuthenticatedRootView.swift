//
//  AuthenticatedRootView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct AuthenticatedRootView: View {
    let container: AuthenticatedAppContainer
    var body: some View {
        NavigationStackContentView(container: container)
    }
}

#Preview {
    AuthenticatedRootView()
}
