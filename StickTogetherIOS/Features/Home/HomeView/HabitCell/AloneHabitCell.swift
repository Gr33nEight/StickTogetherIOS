//
//  AloneHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct AloneHabitCell: View {
    @EnvironmentObject private var profileVM: ProfileViewModel

    let habit: Habit
    let selectedDate: Date
    let isToday: Bool
    let updateCompletion: () -> Void

    private var state: CompletionState {
        habit.completionState(
            on: selectedDate,
            currentUserId: profileVM.safeUser.safeID
        )
    }

    private var done: Bool { state == .both }
    
    private var isPastAndNotDone: Bool {
        selectedDate < Calendar.current.startOfDay(for: Date()) && !done
    }

    var body: some View {
        HabitCellTemplate(
            icon: habit.icon,
            title: habit.title,
            habitCellBackground: isPastAndNotDone ? Color.custom.red :
                done ? Color.custom.primary : Color.custom.grey,
            strikethrough: done,
            showCompletionButton: isToday,
            completionButtonBackground: done ? Color.custom.text : Color.custom.grey,
            showBuddyStatus: nil,
            showCheckmark: done,
            checkmarkColor: done ? Color.custom.primary : Color.custom.text,
            completionButtonBorderColor: done ? .clear : Color(.systemGray),
            updateCompletion: updateCompletion
        ).opacity(isToday ? 1 : 0.6)
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
                habit: coopAsBuddy,
                selectedDate: today,
                buddy: nil,
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
