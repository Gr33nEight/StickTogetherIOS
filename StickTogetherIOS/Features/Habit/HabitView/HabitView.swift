//
//  HabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitView: View {
    let habit: Habit
    let selectedDate: Date
    @State var pickedFrequency: Frequency = .daily()
    @State private var showEditHabitView = false
    @Environment(\.confirm) var confirm
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
                        HabitViewCell(title: "Current streak 🔥", value: "\(habit.streak()) days")
                        HabitViewCell(title: "Habits completed ✅", value: "\(habit.totalCompleted())")
                    }
                    HStack {
                        if let buddyId = habit.buddyId {
                            HabitViewCell(title: "Buddy 👋", value: buddyId)
                        }else{
                            HabitViewCell(title: "", value: "Alone")
                        }
                        HabitViewCell(title: "Current state 🎯", value: habit.completionState(on: selectedDate).text, font: .myBody)
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
                    showEditHabitView.toggle()
                } label: {
                    Image(systemName: "pencil.line")
                }.padding(.trailing, 8)
                Button {
                    confirm(question: "Are you sure you want to delete this habit?") {
                        // delete
                    }
                } label: {
                    Image(systemName: "trash")
                }.padding(.leading, 8)

            }
        }
        .fullScreenCover(isPresented: $showEditHabitView) {
            CreateHabitView(currentUser: User(name: "", email: "")) { i in
                
            }
        }

    }
}
