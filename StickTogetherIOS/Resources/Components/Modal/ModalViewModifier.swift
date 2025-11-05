//
//  CustomModalViewModifier.swift
//  QueensGame
//
//  Created by Natanael Jop on 17/07/2025.
//

import SwiftUI

struct ModalViewModifier: ViewModifier {
    @State var selectedModal: Modal = .closeModal
    var show: Bool {
        selectedModal != .closeModal
    }
    func body(content: Content) -> some View {
        content
            .environment(\.showModal, ModalService(action: { modal in
                selectedModal = modal
            }))
            .overlay {
                ZStack(alignment: .top) {
                    ScreenOverlay(dismiss: dismiss, show: show, blockBackgroundTap: selectedModal.blockBackgroundTap) {
                        switch selectedModal {
                        case .inviteFriend(let invite):
                            InviteFriendModal { id in
                                invite(id)
                            }
                        case .closeModal:
                            EmptyView()
                        }
                    }
                }
            }
    }
    private func dismiss() {
        selectedModal = .closeModal
    }
}

extension View {
    func modal() -> some View {
        self.modifier(ModalViewModifier())
    }
}
