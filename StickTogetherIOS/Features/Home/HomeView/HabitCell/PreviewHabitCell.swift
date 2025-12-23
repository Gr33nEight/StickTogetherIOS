//
//  PreviewHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct PreviewHabitCell: View {
    @EnvironmentObject private var profileVM: ProfileViewModel

    let habit: Habit
    let selectedDate: Date
    let buddy: User?
    let isToday: Bool
    let updateCompletion: () -> Void

    private var state: CompletionState {
        habit.completionState(
            on: selectedDate,
            currentUserId: profileVM.safeUser.safeID
        )
    }

    private var buddyDid: Bool {
        state == .buddy
    }

    var body: some View {
        HabitCellTemplate(
            icon: habit.icon,
            title: habit.title,
            habitCellBackground: buddyDid ? Color.custom.primary : Color.custom.red,
            strikethrough: buddyDid,
            showCompletionButton: false,
            completionButtonBackground: Color.custom.grey,
            showBuddyStatus: HabitCellBuddyInfo(
                buddyStatusColor: Color.custom.text,
                buddyBadgeColor: buddyDid ? Color.custom.primary : Color.custom.red,
                buddyName: buddy?.name,
                showStatusBadge: false,
                buddyMarkedAsDone: buddyDid
            ),
            showCheckmark: false,
            checkmarkColor: .clear,
            completionButtonBorderColor: .clear,
            updateCompletion: {},
        ).opacity(isToday ? 1 : 0.6)
    }
}
