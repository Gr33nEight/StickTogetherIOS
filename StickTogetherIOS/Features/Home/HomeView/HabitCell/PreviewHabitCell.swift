//
//  PreviewHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct PreviewHabitCell: View {
    let habit: Habit
    let selectedDate: Date
    let isToday: Bool

    private var buddyDid: Bool {
        false
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
                buddiesName: [""],
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
