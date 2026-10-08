//
//  LaunchScreenView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 08/10/2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        VStack {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 150)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(Color.custom.background)
    }
}

#Preview {
    LaunchScreenView()
}
