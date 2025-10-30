//
//  CreateHabitViewTitleTextField.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateHabitView {
    var titleTextField: some View {
        HStack(spacing: 15) {
            Button(action: {}, label: {
                Text("➕")
                    .font(.customAppFont(size: 50))
                    .shadow(color: Color.custom.lightGrey, radius: 10)
                    .padding(10)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.custom.text)
                    )
            })
            VStack(alignment: .leading, spacing: 5) {
                Text("Habit Title")
                    .font(.myBody)
                    .foregroundStyle(Color.custom.primary)
                TextField(text: $title, axis: .vertical) {
                    Text("Type here")
                }.font(.customAppFont(size: 26, weight: .medium))
            }
            Spacer()
        }.customCellViewModifier()
        
    }
}
