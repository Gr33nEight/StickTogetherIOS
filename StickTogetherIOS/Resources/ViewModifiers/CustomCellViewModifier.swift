//
//  CustomCellViewModifier.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CustomCellViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.grey)
                )
    }
}
