//
//  DayCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct DayCell: View {
    let dayOfWeek: String
    let dayOfMonth: Int
    var body: some View {
        VStack(alignment: .center){
            Text("\(dayOfMonth)")
                .font(.mySubtitle)
            Text(dayOfWeek)
                .font(.myCaption)
                .fixedSize()
        }.frame(width: 24, height: 50)
        .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.custom.primary)
            )
            
    }
}
