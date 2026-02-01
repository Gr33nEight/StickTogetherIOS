//
//  HabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var appNotificationsVM: AppNotificationsViewModel
    
    let habitId: String?
    let selectedDate: Date
    @State var pickedFrequency: Frequency = .daily()
    @State private var showEditHabitView = false
    
    @Environment(\.navigate) var navigate
    @Environment(\.confirm) var confirm
    @Environment(\.showToastMessage) var toastMessage
    @Namespace var frequencyAnimation
    
    let friends: [User]
    
    var habit: Habit? {
        habitVM.habits.first(where: {$0.id == habitId}) ??
        habitVM.friendsHabits.first(where: {$0.id == habitId})
    }
    
    func buddy(habit: Habit) -> User? {
        guard !habit.buddyId.isEmpty else { return nil }

        return friends.first(where: {
            if let id = $0.id {
                return profileVM.safeUser.safeID == habit.ownerId
                ? id == habit.buddyId : id == habit.ownerId
            }else{
                return false
            }
        })
    }
    
    var body: some View {
        Group {
            if let habit {
                content(habit: habit)
            } else {
                LoadingView()
            }
        }
    }
    
    private func content(habit: Habit) -> some View {
        CustomView(title: "Habit") {
            ScrollView(showsIndicators: false){
                VStack {
                    HStack {
                        Text(habit.icon)
                            .font(.system(size: 35))
                        VStack(alignment: .leading, spacing: 0){
                            Text(habit.title)
                                .font(.mySubtitle)
                            Text(habit.frequency.readableDescription)
                                .font(.myCaption)
                        }
                        Spacer()
                    }.customCellViewModifier()
                    HStack {
                        HabitViewCell(title: "Current streak 🔥", value: "\(habit.streak()) days")
                        HabitViewCell(title: "Habits completed ✅", value: "\(habit.totalCompleted())")
                    }
                    if let buddy = buddy(habit: habit), habit.type != .alone {
                        HStack {
                            HabitViewCell(title: "Buddy 👋", value: buddy.name.capitalized)
                            HabitViewCell(title: "Current state 🎯", value: habit.completionState(
                                on: selectedDate,
                                currentUserId: profileVM.safeUser.safeID
                            ).text, font: .myBody)
                        }
                    }
                    CalendarView(habit: habit, state: {habitVM.habitState(habit, on: $0)}, startDate: habit.startDate)
                }.padding()
                    .foregroundStyle(Color.custom.text)
                    .font(.myBody)
            }
        } buttons: {
            if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                VStack(spacing: 20) {
                    if habit.isMarkedAsDone(by: profileVM.safeUser.safeID, on: selectedDate) {
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
                    if habit.type != .alone {
                        Button(action: {
                            Task {
                                await encourageYourBuddy(habit: habit)
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
                    Image(.edit)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }.padding(.trailing, 8)
                Button {
                    confirm(question: "Are you sure you want to delete this habit?") {
                        Task {
                            let result = await habitVM.deleteHabit(habit.id)
                            
                            switch result {
                            case .success:
                                navigate(.unwind(.home))
                                return
                            case .error(let error):
                                toastMessage(.failed(error))
                            }
                        }
                    }
                } label: {
                    Image(.trash)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }.padding(.leading, 8)
                
            }
        }
        .fullScreenCover(isPresented: $showEditHabitView) {
            
        }
    }
    
    func encourageYourBuddy(habit: Habit) async {
        let appNotification = AppNotification.encouragement(
            senderId: profileVM.safeUser.safeID,
            receiverId: habit.buddyId,
            senderName: profileVM.safeUser.name,
            habitId: habit.id ?? "", content: "Rusz w końcu tą dupę!",
        )
        await appNotificationsVM.sendAppNotification(appNotification)
    }
}
