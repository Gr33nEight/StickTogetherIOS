//
//  HabitListSection.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/11/2025.
//
import SwiftUI

struct HabitListSection: View {
    let visible: [Habit]
    let state: CompletionState
    let selectedDate: Date
    
    let updateCompletion: (Habit) -> Void
    
    var filteredHabits: [Habit] {
        visible.filter { habit in
            let stateForDay = habit.completion[Habit.dayKey(for: selectedDate)] ?? .neither
            return stateForDay == state
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !filteredHabits.isEmpty {
                Text(state.text)
                    .font(.myCaption)
                    .foregroundStyle(Color.custom.secondary)
            }
            ForEach(filteredHabits) { habit in
                NavigationLink {
                    HabitView(habit: habit, selectedDate: selectedDate)
                } label: {
                    HabitCell(habit: habit, updateCompletion: {updateCompletion(habit)}, selectedDate: selectedDate)
                }
            }
            if !filteredHabits.isEmpty {
                VStack { Divider() }
                    .padding(.vertical, 8)
            }
        }
    }
}
