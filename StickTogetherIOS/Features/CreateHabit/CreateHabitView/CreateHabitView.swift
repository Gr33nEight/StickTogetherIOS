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
    @State var autoEmoji = "➕"

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
                        create()
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

    private func create() {
        guard let userId = profileVM.safeUser.id
        else {
            showToastMessage(.warning("You didn't choose icon."))
            return
        }
        var icon = ""
        if let emoji = selectedEmoji?.emoji {
            icon = emoji
        }else{
            icon = autoEmoji
        }
        
        let habitFrequency: Frequency
        switch pickedFrequency {
        case .daily:
            habitFrequency = Frequency.daily(everyDays: interval)
        case .weekly:
            habitFrequency = Frequency.weekly(everyWeeks: interval, daysOfWeek: pickedDays)
        case .monthly:
            habitFrequency = Frequency.monthly(everyMonths: interval)
        }
        
        let initialKey = Habit.dayKey(for: startDate)
        let finalType = buddy == nil ? .alone : type
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
            type: finalType
        )
        
        if addToCalendar {
            do {
                try CalendarManager.shared.addHabitToCalendar(habit: habit)
            } catch {
                // TODO: Handle it properly
            }
        }
        
        Task { await habitVM.createHabit(habit) }
        
        if finalType != .alone {
            guard
                let buddyId = buddy?.id,
                let currentUser = profileVM.currentUser,
                let habitId = habit.id
            else { return }
            
            let appNotification = AppNotification(
                senderId: userId,
                receiverId: buddyId,
                content: "\(currentUser.name) invited you to join his habit: \(title) \(icon)",
                date: Date(),
                type: .habitInvite,
                payload: ["habitId" : habitId])
            
            Task {
                await appNotificationsVM.sendAppNotification(appNotification)
            }
        }
                
        dismiss()
    }
}
