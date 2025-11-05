//
//  ModalService.swift
//  QueensGame
//
//  Created by Natanael Jop on 17/07/2025.
//

import SwiftUI

enum Modal: Identifiable, Equatable {
    case inviteFriend(invite: (String) -> Void)
    case closeModal
    
    var id: String {
        String(describing: self)
    }

    var blockBackgroundTap: Bool {
        switch self {
        case .inviteFriend(_):
            return false
        case .closeModal:
            return true
        }
    }
    
    static func == (lhs: Modal, rhs: Modal) -> Bool {
        switch (lhs, rhs) {
        case (.inviteFriend, .inviteFriend):
            return true
        case (.closeModal, .closeModal):
            return true
        default:
            return false
        }
    }
}
struct ModalService {
    typealias Action = (Modal) -> Void
    let action: Action
    
    func callAsFunction(_ modal: Modal) {
        action(modal)
    }
}
