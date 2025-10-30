//
//  CustomButtonStyles.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    var color: Color = Color.custom.primary
    var textColor: Color = Color.custom.text
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(color))
            .foregroundColor(textColor)
            .font(.myHeadline)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10).stroke(Color.custom.text, lineWidth: 1)
                    RoundedRectangle(cornerRadius: 10).fill(Color.custom.background)
                }
            )
            .foregroundColor(.custom.text)
            .font(.myHeadline)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct DisabledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.custom.tertiary))
            .foregroundColor(.custom.text.opacity(0.5))
            .font(.myHeadline)
            .disabled(true)
    }
}
