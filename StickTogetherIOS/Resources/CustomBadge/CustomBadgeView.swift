//
//  CustomBadge.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/12/2025.
//

import SwiftUI

struct CustomBadgeView: View {
    let number: Int
    var body: some View {
        ZStack {
            if number > 0 {
                Circle()
                    .fill(Color.custom.red)
                    .frame(width: 15, height: 15)
                Text(number < 100 ? "\(number)" : "99+")
                    .font(.customAppFont(size: number >= 10 ? 9 : 11, weight: .semibold))
                    .foregroundColor(Color.custom.text)
            }
        }.offset(x: 5, y: -5)
    }
}

struct CustomBadgeViewModifier: ViewModifier {
    let number: Int
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                CustomBadgeView(number: number)
            }
    }
}

#Preview {
    Image(.bell)
        .resizable()
        .scaledToFit()
        .frame(height: 24)
        .customBadge(number: 0)
        .preferredColorScheme(.dark)
}
