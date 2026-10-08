//
//  LoadingOverlay.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//


import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.regular)
                .tint(Color.custom.primary)
                .padding(28)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 16)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .accessibilityLabel("Loading")
    }
}
