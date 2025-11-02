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
    
    var filteredHabits: [Habit] {
        visible.filter({$0.completion.values.contains(state)})
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
                    HabitCell(habit: habit)
                }
            }
            if !filteredHabits.isEmpty {
                VStack { Divider() }
            }
        }
    }
}
