//
//  FriendsListType.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//
import Foundation

enum FriendsListType: CaseIterable {
    case allFriends, invitationSent, invitationReceived
    
    var text: String {
        switch self {
        case .allFriends: return "All\nFriends"
        case .invitationSent: return "Invitation\nSent"
        case .invitationReceived: return "Invitation\nReceived"
        }
    }
}
