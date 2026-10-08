//
//  HabitType.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/10/2026.
//
import SwiftUI

enum HabitType: Int, CaseIterable, Codable {
    case alone, coop, preview
    
    var text: String {
        switch self {
        case .alone:
            return "Alone"
        case .coop:
            return "Co-op"
        case .preview:
            return "Preview"
        }
    }
}
