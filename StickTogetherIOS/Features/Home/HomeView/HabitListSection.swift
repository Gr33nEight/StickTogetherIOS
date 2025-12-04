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
    
    func iAmOwner(_ ownerId: String) -> Bool {
        currentUserId == ownerId
    }
    
    func buddy(_ habit: Habit) -> User? {
        guard let buddyId = habit.buddyId else { return nil }
        
        return friends.first(where: {
            if let id = $0.id {
                return iAmOwner(habit.ownerId) ? id == buddyId : id == habit.ownerId
            }else{
                return false
            }
        })
    }
    
    var filteredHabits: [Habit] {
        visible.filter { habit in
            let computedState = habit.completionState(
                on: selectedDate,
                currentUserId: currentUserId,
                ownerId: habit.ownerId,
                buddyId: habit.buddyId
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
                    HabitView(habitVM: habitVM, habit: habit, selectedDate: selectedDate, friends: friends)
                } label: {
                    HabitCell(habit: habit, updateCompletion: {updateCompletion(habit)}, selectedDate: selectedDate, buddy: buddy(habit))
                }
            }
            if !filteredHabits.isEmpty {
                VStack { Divider() }
                    .padding(.vertical, 8)
            }
        }
    }
}
