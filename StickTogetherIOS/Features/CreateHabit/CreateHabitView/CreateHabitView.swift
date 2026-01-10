//
//  CreateHabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

struct CreateHabitView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var appNotificationsVM: AppNotificationsViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    
    @State var id: String? = nil
    @State var title = ""
    @State var pickedFrequency: FrequencyType = .daily
    @State var pickedDays = [Weekday]()
    @State var interval = 1
    @State var startDate = Date()
    @State var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State var type: HabitType = .coop
    @State var setReminder = false
    @State var reminderTime = Date()
    @State var buddy: User? = nil
    @State var addToCalendar = false
    @State var showFriendsList = false
    @Namespace var frequencyAnimation
    
    @Environment(\.showToastMessage) var showToastMessage
    @Environment(\.dismiss) var dismiss

    @State var isEmojiPickerPresented = false
    @State var selectedEmoji: Emoji? = nil
    @State var autoEmoji: String? = nil

    var body: some View {
        GeometryReader { _ in
            CustomView(title: "Create Habit") {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        titleTextField
                        frequencySelection
                        inviteFriend
                        reminder
                        addToCalendarView
                    }.padding(.vertical)
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                }
                .padding(.horizontal)
            } buttons: {
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Go back")
                    }.customButtonStyle(.secondary)

                    Button {
                        let results = create()
                        switch results {
                        case .success:
                            dismiss()
                        case .error(let string):
                            showToastMessage(.failed(string))
                        }
                    } label: {
                        Text("Create")
                    }.customButtonStyle(.primary)
                }
            } icons: {}
            .ignoresSafeArea(.keyboard)
        }.emojiPicker(isPresented: $isEmojiPickerPresented, selectedEmoji: $selectedEmoji)
            .onAppear {
                id = UUID().uuidString
            }
            .fullScreenCover(isPresented: $showFriendsList, content: {
                FriendsListView() { buddy in
                    self.buddy = buddy
                }.modal()
                    .environmentObject(friendsVM)
            })
    }

    private func create() -> SuccessOrError {
        
        guard let userId = profileVM.safeUser.id else {
            return .error("Something went wrong")
        }
        
        guard !title.isEmpty else {
            return .error("You have to give this habit a title!")
        }
        
        let icon: String
        if let emoji = selectedEmoji?.emoji {
            icon = emoji
        } else if let autoEmoji {
            icon = autoEmoji
        } else {
            return .error("You have to choose the icon first!")
        }
        
        let habitFrequency: Frequency
        switch pickedFrequency {
        case .daily:
            habitFrequency = .daily(everyDays: interval)
        case .weekly:
            habitFrequency = .weekly(everyWeeks: interval, daysOfWeek: pickedDays)
        case .monthly:
            habitFrequency = .monthly(everyMonths: interval)
        }
        
        let initialKey = Habit.dayKey(for: startDate)
        
        let habit = Habit(
            id: id,
            title: title,
            icon: icon,
            ownerId: userId,
            frequency: habitFrequency,
            startDate: startDate,
            endDate: endDate,
            reminderTime: setReminder ? reminderTime : nil,
            completion: [initialKey: []],
            type: type
        )
        
        let appNotification: AppNotification?
        if type != .alone {
            guard let buddy else {
                return .error("You have to choose a buddy to share this habit with!")
            }
            
            appNotification = AppNotification(
                senderId: userId,
                receiverId: buddy.safeID,
                content: "\(profileVM.safeUser.name) invited you to join his habit: \(title) \(icon)",
                date: Date(),
                type: .habitInvite,
                payload: ["habitId": habit.id ?? ""]
            )
        } else {
            appNotification = nil
        }
        
        Task {
            let result = await habitVM.createHabit(habit)
            guard result.isSuccess else { return }
            
            if addToCalendar {
                try? CalendarManager.shared.addHabitToCalendar(habit: habit)
            }
            
            if let appNotification {
                await appNotificationsVM.sendAppNotification(appNotification)
            }
        }
        
        return .success
    }
}
