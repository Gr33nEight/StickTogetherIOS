//
//  HabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitView: View {
    @StateObject var viewModel: HabitViewModel
    
    @Environment(\.navigate) var navigate
    @Environment(\.confirm) var confirm
    @Environment(\.showToastMessage) var toastMessage
    
    @Namespace var frequencyAnimation
    
    var body: some View {
        CustomView(title: "Habit") {
            ScrollView(showsIndicators: false){
                VStack {
                    HStack {
                        Text(viewModel.habit.icon)
                            .font(.system(size: 35))
                        VStack(alignment: .leading, spacing: 0){
                            Text(viewModel.habit.title)
                                .font(.mySubtitle)
                            Text(viewModel.habit.frequency.readableDescription)
                                .font(.myCaption)
                        }
                        Spacer()
                    }.customCellViewModifier()
                    HStack {
                        HabitViewCell(title: "Current streak 🔥", value: "\(viewModel.habit.currentStreak) days")
                        HabitViewCell(title: "Longest streak 🏆", value: "\(viewModel.habit.longestStreak) days")
                    }
                    HStack {
                        HabitViewCell(title: "Habits completed ✅", value: "\(viewModel.habit.allCompleted)")
                        HabitViewCell(title: "Current state 🎯", value: viewModel.completionState.text, font: .myBody)
                    }
                    
                    if viewModel.habit.type != .alone && !viewModel.buddies.isEmpty  {
                        HabitViewCell(title: "Buddy 👋", value: viewModel.buddies.first!.name)
                    }
                    
//                    CalendarView(state: {habitVM.habitState(habit, on: $0)}, startDate: habit.startDate)
                }.padding()
                    .foregroundStyle(Color.custom.text)
                    .font(.myBody)
            }
        } buttons: {
            if Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: Date()) {
                VStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await viewModel.toggleHabitCompletion()
                        }
                    }, label: {
                        Text(viewModel.isDone ? "Mark as undone" : "Mark as done")
                    })
                    .customButtonStyle(viewModel.isDone ? .secondary : .primary)
                    if viewModel.habit.type != .alone {
                        Button(action: {
                            Task {
                                await viewModel.encourageBuddies()
                            }
                        }, label: {
                            Text("Encourage your buddy")
                        })
                        .customButtonStyle(.secondary)
                    }
                }
            }
        } icons: {
            HStack(spacing: 0) {
                Button {
//                    showEditHabitView.toggle()
                } label: {
                    Image(.edit)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }.padding(.trailing, 8)
                Button {
                    confirm(question: "Are you sure you want to delete this habit?") {
                        Task { await viewModel.deleteHabit() }
                    }
                } label: {
                    Image(.trash)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }.padding(.leading, 8)
                
            }
        }
//        .fullScreenCover(isPresented: $showEditHabitView) {
//            
//        }
        .onChange(of: viewModel.event) { _, event in
            guard let event else { return }
            
            switch event {
            case .dimsiss:
                navigate(.unwind(nil))
            case .showToastMessage(let message):
                toastMessage(message)
            }
            
            viewModel.event = nil
        }
        .task {
            await viewModel.onAppear()
        }
    }
}
