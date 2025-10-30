//
//  Font+App.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

enum CustomFont {
    case title
    case subtitle
    case headline
    case body
    case caption
    case custom(size: CGFloat, weight: Font.Weight = .regular)
    
    private var family: String { "HelveticaNeue" }
    
    var font: Font {
        switch self {
        case .title:
            return Font.custom("\(family)-Heavy", size: 32, relativeTo: .largeTitle)
        case .subtitle:
            return Font.custom("\(family)-Bold", size: 20, relativeTo: .title)
        case .headline:
            return Font.custom("\(family)-Medium", size: 18, relativeTo: .body)
        case .body:
            return Font.custom("\(family)-Medium", size: 16, relativeTo: .caption)
        case .caption:
            return Font.custom("\(family)-Light", size: 14, relativeTo: .caption)
        case .custom(let size, let weight):
            return Font.custom("\(family)-\(weight.fontNameSuffix)", size: size)
        }
    }
}

private extension Font.Weight {
    var fontNameSuffix: String {
        switch self {
        case .ultraLight: return "UltraLight"
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .heavy: return "Heavy"
        case .black: return "Black"
        default: return "Regular"
        }
    }
}

