//
//  FontExtension.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

extension Font {
    static var myTitle: Font { CustomFont.title.font }
    static var mySubtitle: Font { CustomFont.subtitle.font }
    static var myHeadline: Font { CustomFont.headline.font }
    static var myBody: Font { CustomFont.body.font }
    static var myCaption: Font { CustomFont.caption.font }

    static func customAppFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        CustomFont.custom(size: size, weight: weight).font
    }
}
