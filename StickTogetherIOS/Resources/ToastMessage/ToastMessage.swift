//
//  ToastMessageType.swift
//  PanstwaMiasta
//
//  Created by Natanael Jop on 01/11/2023.
//

import SwiftUI

enum ToastMessage: Identifiable, Hashable, Equatable {
    var id: Self { self }
    
    case failed(String)
    case warning(String)
    case info(String)
    case succes(String)
    case none

    var color: Color {
        switch self {
        case .failed:
            return .custom.red
        case .warning:
            return .custom.yellow
        case .info:
            return .custom.blue
        case .succes:
            return .custom.primary
        case .none:
            return .clear
        }
    }

    var title: String {
        switch self {
        case .failed:
            return "Error"
        case .warning:
            return "Warning"
        case .info:
            return "Info"
        case .succes:
            return "Success"
        case .none:
            return ""
        }
    }

    var icon: Image {
        switch self {
        case .failed:
            return Image(systemName: "xmark.circle.fill")
        case .warning:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .info:
            return Image(systemName: "info.circle.fill")
        case .succes:
            return Image(systemName: "checkmark.circle.fill")
        case .none:
            return Image(systemName: "questionmark")
        }
    }

    var content: String {
        switch self {
        case .failed(let error):
            return error
        case .warning(let string):
            return string
        case .info(let string):
            return string
        case .succes(let string):
            return string
        case .none:
            return ""
        }
    }
}
