//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HomeView: View {
    let signOut: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            header
            calendar
            content
                .padding(.horizontal, 20)
        }
        .background(
            Color.custom.background
        )
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
    }
}
