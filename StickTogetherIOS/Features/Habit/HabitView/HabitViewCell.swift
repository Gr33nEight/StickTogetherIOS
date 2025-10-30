//
//  HabitViewCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitViewCell: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.myCaption)
            Text(value)
                .font(.mySubtitle)
                .fixedSize()
        }.frame(maxWidth: .infinity, alignment: .leading)
        .customCellViewModifier()
    }
}
