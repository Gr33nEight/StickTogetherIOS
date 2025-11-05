//
//  CreateHabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

struct CreateHabitView: View {
    @ObservedObject var friendsVM: FriendsViewModel
    
    @State var id: String? = nil
    @State var title = ""
    @State var pickedFrequency: FrequencyType = .daily
    @State var pickedDays = [Weekday]()
    @State var interval = 1
    @State var startDate = Date()
    @State var setReminder = false
    @State var reminderTime = Date()
    @State var alone = false
    @State var buddyId: String = ""
    @State var showFriendsList = false
    @Namespace var frequencyAnimation
    
    @Environment(\.showToastMessage) var showToastMessage
    @Environment(\.dismiss) var dismiss

    @State var isEmojiPickerPresented = false
    @State var selectedEmoji: Emoji? = nil

    let currentUser: User
    let createHabit: (Habit) -> Void

    var body: some View {
        GeometryReader { _ in
            CustomView(title: "Create Habit") {
                ScrollView {
                    VStack(spacing: 20) {
                        titleTextField
                        frequencySelection
                        reminder
                        inviteFriend
                    }
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                }
                .padding()
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
                FriendsListView(friendsVM: friendsVM, currentUser: currentUser)
                    .modal()
            })
    }

    private func create() {
        guard let userId = currentUser.id,
        let icon = selectedEmoji?.emoji
        else {
            showToastMessage(.warning("You didn't choose icon."))
            return
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
        let habit = Habit(
            id: id,
            title: title,
            icon: icon,
            ownerId: userId,
            buddyId: alone ? nil : buddyId,
            frequency: habitFrequency,
            startDate: startDate,
            reminderTime: setReminder ? reminderTime : nil,
            alone: alone,
            completion: [initialKey: .neither]
        )

        createHabit(habit)
        dismiss()
    }
}
