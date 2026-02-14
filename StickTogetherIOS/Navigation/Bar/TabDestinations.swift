//
//  NavigationDestinations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

enum TabDestinations: String, CaseIterable {
    case home = "Add Habit", friends, settings
    
    var icon: ImageResource {
        switch self {
        case .home:
            return .home
        case .friends:
            return .users
        case .settings:
            return .settings
        }
    }
}
