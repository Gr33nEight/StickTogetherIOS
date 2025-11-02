//
//  HabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitCell: View {
    let habit: Habit
    var body: some View {
        HStack(spacing: 15) {
            Text(habit.icon)
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.custom.text)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.title)
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                Text(habit.frequency.readableDescription)
                    .font(.customAppFont(size: 12, weight: .medium))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            ZStack{
                Circle()
                    .fill(Color.custom.lightGrey)
                Circle()
                    .stroke(lineWidth: 1.2)
                    .fill(Color.custom.text)
                    .padding(15)
            }.frame(height: 50)
                .padding(.vertical)
        }.padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.custom.grey)
        )
    }
}
