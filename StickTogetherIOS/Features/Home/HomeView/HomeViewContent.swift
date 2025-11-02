//
//  HomeViewContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    @ViewBuilder
    var content: some View {
        HStack {
            Text("Track your\nhabit")
                .font(.myTitle)
            Spacer()
            NavigationLink {
                CreateHabitView(currentUser: currentUser) { habit in
                    Task { await vm.createHabit(habit) }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                    Image(systemName: "plus")
                }
                .frame(width: 50)
            }
        }.padding(.horizontal, 20)
        .foregroundColor(.custom.text)

        let visible = vm.habits.filter { $0.isScheduled(on: selectedDate) }

        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    if visible.isEmpty {
                        Text("No habits scheduled for this day")
                            .foregroundStyle(Color.custom.grey)
                            .padding(.top, 20)
                    } else {
                        ForEach(visible) { habit in
                            NavigationLink {
                                HabitView(habit: habit, selectedDate: selectedDate)
                            } label: {
                                HabitCell(habit: habit)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
            }
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                Color.black.opacity(0.5)
                Button {
                    selectedDate = Date()
                } label: {
                    Text("Return to today")
                }.customButtonStyle(.primary)
                    .padding(20)
                    .padding(.bottom, 10)
            }
            
        }
    }
}
