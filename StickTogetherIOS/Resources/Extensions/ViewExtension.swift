//
//  ViewExtension.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func customButtonStyle(_ style: ButtonStyles, color: Color = Color.custom.primary, textColor: Color = Color.custom.text) -> some View {
        switch style {
        case .primary: buttonStyle(PrimaryButton(color: color, textColor: textColor))
        case .secondary: buttonStyle(SecondaryButton())
        case .disabled: buttonStyle(DisabledButton())
        }
    }
    
    func customCellViewModifier() -> some View {
        modifier(CustomCellViewModifier())
    }
    
    func customBadge(number: Int, offset: CGPoint = .zero) -> some View {
        modifier(CustomBadgeViewModifier(number: number, offset: offset))
    }
}
