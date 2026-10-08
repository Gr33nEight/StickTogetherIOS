//
//  FriendsViewEvent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

enum FriendsViewEvent: Equatable {
    case showToastMessage(ToastMessage)
    case showInviteModal
    case closeModal
    case dimsiss
}
