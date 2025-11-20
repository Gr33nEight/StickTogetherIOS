//
//  BaseCompletionState.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/11/2025.
//

import SwiftUI

enum HabitState {
    case none
    case skipped
    case done
    
    var color: Color {
        switch self {
        case .done:
            return Color.custom.primary
        case .skipped:
            return Color.custom.red
        case .none:
            return Color.custom.grey
        }
    }
    
    var textColor: Color {
        switch self {
        case .done:
            return Color.custom.text
        case .skipped:
            return Color.custom.text
        case .none:
            return Color(.systemGray)
        }
    }
}
