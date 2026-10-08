//
//  CoopHabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/12/2025.
//

import SwiftUI

struct CoopHabitCell: View {
    let habit: Habit
    let buddyInfos: [HabitCellBuddyInfo]
    let selectedDate: Date
    let isToday: Bool
    let onToggle: () -> Void

    var state: CompletionState

    private var done: Bool { state == .all }
    private var iDid: Bool { state == .onlyMe || state == .all }

    private var isPastAndNotDone: Bool {
        selectedDate < Calendar.current.startOfDay(for: Date()) && !done
    }
    
    var body: some View {
        ZStack {
            HabitCellTemplate(
                icon: habit.icon,
                title: habit.title,
                habitCellBackground: isPastAndNotDone
                    ? Color.custom.red
                    : done
                        ? Color.custom.primary
                        : Color.custom.grey,
                strikethrough: iDid || done,
                showCompletionButton: isToday,
                completionButtonBackground: done
                    ? Color.custom.text
                    : iDid
                        ? Color.custom.primary
                        : Color.custom.grey,
                showBuddyStatus: buddyInfos,
                showCheckmark: iDid || done,
                checkmarkColor: done
                    ? Color.custom.primary
                    : Color.custom.text,
                completionButtonBorderColor: iDid || done
                    ? .clear
                    : Color(.systemGray),
                updateCompletion: onToggle
            )
            .opacity(isToday ? 1 : 0.6)
        }
    }
}
