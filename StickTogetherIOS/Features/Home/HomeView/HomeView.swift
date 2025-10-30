//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            header
            calendar
            content
            Spacer()
        }.padding(.horizontal, 20)
        .background(
            Color.custom.background
        )
    }
}
