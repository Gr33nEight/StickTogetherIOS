//
//  CustomToastMessageViewModifier.swift
//  QueensGame
//
//  Created by Natanael Jop on 16/07/2025.
//
import SwiftUI

struct ToastMessageViewModifier: ViewModifier {
    @State var selectedToast: ToastMessage?
    func body(content: Content) -> some View {
        content
            .environment(\.showToastMessage, ToastMessageService(action: { toast in
                if selectedToast != nil {
                    Task {
                        selectedToast = nil
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        selectedToast = toast
                    }
                }else{
                    selectedToast = toast
                }
                
            }))
            .overlay(ToastMessageView(toast: $selectedToast), alignment: .top)
    }
}

extension View {
    func customToastMessage() -> some View {
        self.modifier(ToastMessageViewModifier())
    }
}
