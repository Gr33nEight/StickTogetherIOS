//
//  CreateHabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CreateHabitView: View {
    @State var title = ""
    @State var pickedFrequency: FrequencyType = .daily
    @State var pickedDays = [Weekday]()
    @State var interval = 1
    @State var startDate = Date()
    @State var setReminder = false
    @State var reminderTime = Date()
    @State var alone = false
    @Namespace var frequencyAnimation
    @Environment(\.dismiss) var dismiss

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
        }
    }

    private func create() {
        guard let userId = currentUser.id else { return }
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
            title: title,
            icon: "❤️",
            ownerId: userId,
            buddyId: nil,
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
