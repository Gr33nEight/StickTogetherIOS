//
//  HabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitCell: View {
    let habitItem: HabitListItem
    let selectedDate: Date
    let onToggle: () -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        ZStack {
            switch habitItem.habit.type {
            case .alone:
                AloneHabitCell(
                    habit: habitItem.habit,
                    selectedDate: selectedDate,
                    isToday: isToday,
                    onToggle: onToggle,
                    state: habitItem.state
                )

            case .coop:
                CoopHabitCell(
                    habit: habitItem.habit,
                    buddyInfos: habitItem.buddyInfos,
                    selectedDate: selectedDate,
                    isToday: isToday,
                    onToggle: onToggle,
                    state: habitItem.state
                )

            case .preview:
                if habitItem.isOwner {
                    AloneHabitCell(
                        habit: habitItem.habit,
                        selectedDate: selectedDate,
                        isToday: isToday,
                        onToggle: onToggle,
                        state: habitItem.state
                    )
                } else {
                    PreviewHabitCell(
                        habit: habitItem.habit,
                        selectedDate: selectedDate,
                        isToday: isToday,
                    )
                }
            }
        }.cornerRadius(10)
    }
}
