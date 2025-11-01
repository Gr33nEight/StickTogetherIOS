//
//  HabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitView: View {
    let habit: Habit
    @State var pickedFrequency: Frequency = .daily()
    @Namespace var frequencyAnimation
    var body: some View {
        CustomView(title: "Habit") {
            ScrollView(showsIndicators: false){
                VStack {
                    HStack {
                        Text(habit.icon)
                            .font(.system(size: 35))
                        VStack(alignment: .leading, spacing: 0){
                            Text(habit.title)
                                .font(.mySubtitle)
                            Text("Everyday")
                                .font(.myCaption)
                        }
                        Spacer()
                    }.customCellViewModifier()
                    HStack {
                        HabitViewCell(title: "Current streak 🔥", value: "\(habit.streak) days")
                        HabitViewCell(title: "Habits completed ✅", value: "\(habit.totalCompleted)")
                    }
                    HStack {
                        HabitViewCell(title: "Buddy 👋", value: habit.buddyId ?? "Alex")
                        HabitViewCell(title: "Current state 🎯", value: habit.state.text, font: .myBody)
                    }
                    CalendarView()
                }.padding()
                .foregroundStyle(Color.custom.text)
                    .font(.myBody)
            }
        } buttons: {
            VStack(spacing: 20) {
                Button(action: {}, label: {
                    Text("Mark as done")
                })
                .customButtonStyle(.primary)
                Button(action: {}, label: {
                    Text("Encourage your buddy")
                })
                .customButtonStyle(.secondary)
            }
        } icons: {
            HStack(spacing: 0) {
                Button {
                    
                } label: {
                    Image(systemName: "pencil.line")
                }.padding(.trailing, 8)
                Button {
                    
                } label: {
                    Image(systemName: "trash")
                }.padding(.leading, 8)

            }
        }

    }
}

#Preview {
    HabitView(habit: Constants.sampleHabits[0])
        .preferredColorScheme(.dark)
}
