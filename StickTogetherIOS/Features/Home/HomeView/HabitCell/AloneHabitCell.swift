//
//  AloneHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct AloneHabitCell: View {
    let habit: Habit
    let selectedDate: Date
    let isToday: Bool
    let updateCompletion: () -> Void

    private var state: CompletionState {
        habit.completionState(
            on: selectedDate,
            currentUserId: habit.ownerId
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
