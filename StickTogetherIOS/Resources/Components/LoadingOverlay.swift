//
//  LoadingOverlay.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//


import SwiftUI

struct LoadingOverlay: View {
    @EnvironmentObject var loading: LoadingManager

    var body: some View {
        ZStack {
            if loading.isLoading {
                Color.black.opacity(0.36)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(0)

                VStack {
                    ProgressView()
                        .tint(.accent)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground).opacity(0.08))
                        )
                }
                .padding(6)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: loading.isLoading)
        .allowsHitTesting(loading.isLoading)
        .accessibility(hidden: !loading.isLoading)
    }
}

struct CustomProgressView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Circle()
                    .fill(Color.custom.primary)
                    .frame(width: 5, height: 5)
                    .offset(y: animate ? 20 : 0)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .animation(Animation.linear(duration: 1).repeatForever().delay(Double(i) * 0.1), value: animate)
            }
        }
        .onAppear { animate.toggle() }
    }
}

#Preview {
    CustomProgressView()
}
