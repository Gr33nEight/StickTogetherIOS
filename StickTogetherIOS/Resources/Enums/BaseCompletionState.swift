//
//  BaseCompletionState.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/11/2025.
//

import SwiftUI

enum BaseCompletionState: Int, Codable, CaseIterable {
    case done, skipped, none
    
    var text: String {
        switch self {
        case .done:
            "Done"
        case .skipped:
            "Skipped"
        case .none:
            ""
        }
    }
    
    var color: Color {
        switch self {
        case .done:
            return Color.custom.secondary
        case .skipped:
            return Color.custom.red
        case .none:
            return Color.custom.grey
        }
    }
    
    var textColor: Color {
        switch self {
        case .done:
            return Color.custom.grey
        case .skipped:
            return Color.custom.text
        case .none:
            return Color(.systemGray)
        }
    }
}
