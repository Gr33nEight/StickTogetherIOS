//
//  HabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitView: View {
    @ObservedObject var habitVM: HabitViewModel
    
    let habit: Habit
    let selectedDate: Date
    @State var pickedFrequency: Frequency = .daily()
    @State private var showEditHabitView = false
    
    @Environment(\.confirm) var confirm
    @Environment(\.showToastMessage) var toastMessage
    @Namespace var frequencyAnimation
    
    let currentUserId: String
    let friends: [User]
    
    var iAmOwner: Bool {
        currentUserId == habit.ownerId
    }
    
    func buddy() -> User? {
        guard let buddyId = habit.buddyId else { return nil }
        
        return friends.first(where: {
            if let id = $0.id {
                return iAmOwner ? id == buddyId : id == habit.ownerId
            }else{
                return false
            }
        })
    }
    
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
                    if let buddy = buddy(), !habit.alone {
                        HStack {
                            HabitViewCell(title: "Buddy 👋", value: buddy.name.capitalized)
                            HabitViewCell(title: "Current state 🎯", value: habit.completionState(
                                on: selectedDate,
                                currentUserId: currentUserId,
                                buddyId: currentUserId == habit.ownerId ? habit.buddyId : habit.ownerId
                            ).text, font: .myBody)
                        }
                    }
                    CalendarView(wasDone: {habitVM.wasDone(on: $0, habit: habit)}, startDate: habit.startDate)
                }.padding()
                    .foregroundStyle(Color.custom.text)
                    .font(.myBody)
            }
        } buttons: {
            if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                VStack(spacing: 20) {
                    if habit.isMarkedAsDone(by: currentUserId, on: selectedDate) {
                        Button(action: {
                            Task { await habitVM.markHabitAsCompleted(habit, date: selectedDate) }
                        }, label: {
                            Text("Mark as undone")
                        })
                        .customButtonStyle(.secondary)
                    }else{
                        Button(action: {
                            Task { await habitVM.markHabitAsCompleted(habit, date: selectedDate) }
                        }, label: {
                            Text("Mark as done")
                        })
                        .customButtonStyle(.primary)
                    }
                    if !habit.alone {
                        Button(action: {
                            Task {
                                await habitVM.encourageYourBuddy()
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
                    showEditHabitView.toggle()
                } label: {
                    Image(systemName: "pencil.line")
                }.padding(.trailing, 8)
                Button {
                    confirm(question: "Are you sure you want to delete this habit?") {
                        Task {
                            let result = await habitVM.deleteHabit(habit.id)
                            if let error = result.errorMessage {
                                toastMessage(.failed(error))
                            }
                        }
                    }
                } label: {
                    Image(systemName: "trash")
                }.padding(.leading, 8)
                
            }
        }
        .fullScreenCover(isPresented: $showEditHabitView) {
            
        }
    }
}
