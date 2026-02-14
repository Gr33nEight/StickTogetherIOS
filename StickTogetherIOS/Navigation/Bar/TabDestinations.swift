//
//  NavigationDestinations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

enum TabDestinations: String, CaseIterable {
    case home = "Add Habit", friends, /*chats = "Messages", stats,*/ settings
    
    var icon: ImageResource {
        switch self {
        case .home:
            return .home
//        case .stats:
//            return .chart
//        case .chats:
//            return .message
        case .friends:
            return .users
        case .settings:
            return .settings
        }
    }
}
