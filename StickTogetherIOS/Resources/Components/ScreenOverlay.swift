//
//  ScreenOverlay.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 03/11/2025.
//
import SwiftUI

struct ScreenOverlay<Content: View>: View {
    let dismiss: () -> Void
    let show: Bool
    var color: Color = Color.custom.primary
    var bgColor: Color = Color.custom.background
    var blockBackgroundTap: Bool = false
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            Blur(style: .dark)
                .ignoresSafeArea()
                .opacity(show ? 1 : 0)
                .zIndex(-1)
                .onTapGesture {
                    if !blockBackgroundTap {
                        dismiss()
                    }
                }
            if show {
                ZStack {
                    content
                }.padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(bgColor)
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(lineWidth: 5)
                                .fill(color)
                        }
                    )
                    .transition(.asymmetric(insertion: .scale, removal: .scale.combined(with: .opacity)))
                    .padding(20)
            }
        }.animation(.easeInOut, value: show)
    }
}
