//
//  AuthenticatedRootView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct UnauthenticatedRootView: View {
    let container: UnauthenticatedAppContainer
    var body: some View {
        container.makeLoginView()
    }
}
