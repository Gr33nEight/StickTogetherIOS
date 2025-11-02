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
                VStack(spacing: 0) {
                    if visible.isEmpty {
                        Text("No habits scheduled for this day")
                            .foregroundStyle(Color.custom.lightGrey)
                            .font(.mySubtitle)
                            .padding(.top, UIScreen.main.bounds.width / 3)
                    } else {
                        ForEach(CompletionState.allCases, id: \.self) { state in
                            HabitListSection(visible: visible, state: state, selectedDate: selectedDate) { habit in
                                Task { await vm.markHabitAsCompleted(habit, date: selectedDate) }
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
            }
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
//                Color.black.opacity(0.3)
                Button {
                    selectedDate = Date()
                    pageIndex = centerPage
                    baseWeekAnchor = selectedDate
                } label: {
                    Text("Return to today")
                }.customButtonStyle(.primary)
                    .padding(20)
                    .padding(.bottom, 10)
            }
            
        }
    }
}
