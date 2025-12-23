//
//  CoopHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct CoopHabitCell: View {
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

    private var done: Bool { state == .both }
    private var iDid: Bool { state == .me || state == .both }
    private var buddyDid: Bool { state == .buddy || state == .both }

    private var isPastAndNotDone: Bool {
        selectedDate < Calendar.current.startOfDay(for: Date()) && !done
    }

    private var buddyColor: Color {
        if done || isPastAndNotDone { return Color.custom.text }
        return buddyDid ? Color.custom.primary : Color.custom.red
    }
    
    var body: some View {
        HabitCellTemplate(
            icon: habit.icon,
            title: habit.title,
            habitCellBackground: isPastAndNotDone ? Color.custom.red :
                done ? Color.custom.primary : Color.custom.grey,
            strikethrough: iDid || done,
            showCompletionButton: isToday,
            completionButtonBackground: done ? Color.custom.text :
                iDid ? Color.custom.primary : Color.custom.grey,
            showBuddyStatus: HabitCellBuddyInfo(
                buddyStatusColor: buddyColor,
                buddyBadgeColor: done
                    ? (buddyDid ? Color.custom.primary : Color.custom.red)
                : isToday ? Color.custom.text : Color.custom.red,
                buddyName: buddy?.name,
                showStatusBadge: true,
                buddyMarkedAsDone: buddyDid
            ),
            showCheckmark: iDid || done,
            checkmarkColor: done ? Color.custom.primary : Color.custom.text,
            completionButtonBorderColor: iDid || done ? .clear : Color(.systemGray),
            updateCompletion: updateCompletion
        ).opacity(isToday ? 1 : 0.6)
    }
}
