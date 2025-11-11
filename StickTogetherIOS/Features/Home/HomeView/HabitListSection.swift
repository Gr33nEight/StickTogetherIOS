//
//  HabitListSection.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/11/2025.
//
import SwiftUI

struct HabitListSection: View {
    @ObservedObject var habitVM: HabitViewModel
    let visible: [Habit]
    let state: CompletionState
    let selectedDate: Date
    let currentUserId: String
    let friends: [User]
    
    let updateCompletion: (Habit) -> Void
    
    var filteredHabits: [Habit] {
        visible.filter { habit in
            let computedState = habit.completionState(
                on: selectedDate,
                currentUserId: currentUserId,
                buddyId: currentUserId == habit.ownerId ? habit.buddyId : habit.ownerId
            )
            return computedState == state
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
                    HabitView(habitVM: habitVM, habit: habit, selectedDate: selectedDate, currentUserId: currentUserId, friends: friends)
                } label: {
                    HabitCell(habit: habit, updateCompletion: {updateCompletion(habit)}, selectedDate: selectedDate, currentUserId: currentUserId)
                }
            }
            if !filteredHabits.isEmpty {
                VStack { Divider() }
                    .padding(.vertical, 8)
            }
        }
    }
}
