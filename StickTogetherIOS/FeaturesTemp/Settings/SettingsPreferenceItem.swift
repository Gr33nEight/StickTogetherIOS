//
//  SettingsPreferenceItem.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//
import SwiftUI

enum SettingsPreferenceItem: Identifiable {
    case toggle(icon: String, text: String, value: Binding<Bool>)
    case picker(icon: String, text: String, options: [String], selection: Binding<String>)
    case custom(icon: String, text: String, view: AnyView)

    var id: String {
        switch self {
        case .toggle(_, let text, _): return "toggle_\(text)"
        case .picker(_, let text, _, _): return "picker_\(text)"
        case .custom(_, let text, _): return "custom_\(text)"
        }
    }
}
