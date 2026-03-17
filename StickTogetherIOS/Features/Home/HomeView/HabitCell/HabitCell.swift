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
