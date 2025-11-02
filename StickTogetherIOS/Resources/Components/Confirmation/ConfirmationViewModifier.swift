//
//  ConfirmationViewModel.swift
//  QueensGame
//
//  Created by Natanael Jop on 17/07/2025.
//

import SwiftUI

struct ConfirmationViewModifier: ViewModifier {
    @State var confirmation: Confirmation?
    
    var show: Bool {
        confirmation != nil
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.confirm, ConfirmationService(action: { conf in
                confirmation = conf
            }))
            .overlay {
                ZStack {
                    Color.black.opacity(show ? 0.7 : 0)
                    if let unwrappedConfirmation = confirmation {
                        ConfirmView(confirmation: unwrappedConfirmation) {
                            confirmation = nil
                        }.transition(.scale)
                    }
                }.animation(.easeInOut, value: show)
                .ignoresSafeArea()
            }
    }
}

extension View {
    func confirmation() -> some View {
        self.modifier(ConfirmationViewModifier())
    }
}
