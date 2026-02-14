//
//  Route.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/12/2025.
//

import SwiftUI

enum Route: Hashable, Codable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .habit(_):
            break
        case .createHabit:
            break
        case .notifications:
            break
        }
    }
    
    case habit(HabitViewContainer)
    case createHabit
    case notifications
}
