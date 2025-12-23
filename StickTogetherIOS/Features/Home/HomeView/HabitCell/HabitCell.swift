//
//  HabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitCell: View {
    @EnvironmentObject private var profileVM: ProfileViewModel

    let habit: Habit
    let selectedDate: Date
    let buddy: User?
    let updateCompletion: () -> Void

    private var iAmOwner: Bool {
        habit.ownerId == profileVM.safeUser.safeID
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        ZStack {
            switch habit.type {
            case .alone:
                AloneHabitCell(
                    habit: habit,
                    selectedDate: selectedDate,
                    isToday: isToday,
                    updateCompletion: updateCompletion
                )

            case .coop:
                CoopHabitCell(
                    habit: habit,
                    selectedDate: selectedDate,
                    buddy: buddy,
                    isToday: isToday,
                    updateCompletion: updateCompletion
                )

            case .preview:
                if iAmOwner {
                    AloneHabitCell(
                        habit: habit,
                        selectedDate: selectedDate,
                        isToday: isToday,
                        updateCompletion: updateCompletion
                    )
                } else {
                    PreviewHabitCell(
                        habit: habit,
                        selectedDate: selectedDate,
                        buddy: buddy,
                        isToday: isToday,
                        updateCompletion: updateCompletion
                    )
                }
            }
        }.cornerRadius(10)
    }
}

#Preview {
    let me = User(id: "me", name: "Me", email: "")
    let buddy = User(id: "buddy", name: "Alex", email: "")

    let today = Date()

    let aloneHabit = Habit(
        id: "alone",
        title: "Drink Water",
        icon: "💧",
        ownerId: me.id!,
        buddyId: "",
        frequency: Frequency(type: .daily), type: .alone
    )

    let coopAsOwner = Habit(
        id: "coop-owner",
        title: "Morning Run",
        icon: "🏃‍♂️",
        ownerId: me.id!,
        buddyId: buddy.id!,
        frequency: Frequency(type: .daily), type: .coop
    )

    let coopAsBuddy = Habit(
        id: "coop-buddy",
        title: "Read Book",
        icon: "📖",
        ownerId: buddy.id!,
        buddyId: me.id!,
        frequency: Frequency(type: .daily), type: .coop
    )

    let previewAsOwner = Habit(
        id: "preview-owner",
        title: "Meditation",
        icon: "🧘‍♂️",
        ownerId: me.id!,
        buddyId: buddy.id!,
        frequency: Frequency(type: .daily), type: .preview
    )

    let previewAsBuddy = Habit(
        id: "preview-buddy",
        title: "Cold Shower",
        icon: "🚿",
        ownerId: buddy.id!,
        buddyId: me.id!,
        frequency: Frequency(type: .daily), type: .preview
    )

    ZStack {
        Color.custom.background

        VStack(spacing: 12) {
            HabitCell(
                habit: aloneHabit,
                selectedDate: today,
                buddy: nil,
                updateCompletion: {}
            )

            HabitCell(
                habit: coopAsOwner,
                selectedDate: today,
                buddy: buddy,
                updateCompletion: {}
            )

            HabitCell(
                habit: coopAsBuddy,
                selectedDate: today,
                buddy: buddy,
                updateCompletion: {}
            )

            HabitCell(
                habit: previewAsOwner,
                selectedDate: today,
                buddy: buddy,
                updateCompletion: {}
            )

            HabitCell(
                habit: previewAsBuddy,
                selectedDate: today,
                buddy: me,
                updateCompletion: {}
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
    .environmentObject(
        ProfileViewModel(profileService: MockProfileService())
    )
}
