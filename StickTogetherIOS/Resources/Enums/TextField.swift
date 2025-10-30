//
//  TextField.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

enum TextFieldState: Equatable {
    case filled
    case notFilled
    case focused
    case error(String)

    var borderColor: Color {
        switch self {
        case .notFilled: return .clear
        case .focused, .filled: return .custom.primary
        case .error: return .custom.red
        }
    }
    var textColor: Color {
        switch self {
        case .notFilled: return .custom.background
        case .focused, .filled: return .custom.primary
        case .error: return .custom.red
        }
    }
    var backgroundColor: Color {
        switch self {
        case .notFilled, .error: return .custom.grey
        case .focused, .filled: return .custom.background
        }
    }
}

