//
//  HabitCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HabitCell: View {
    let habit: Habit
    let updateCompletion: () -> Void
    let selectedDate: Date
    let currentUserId: String?
    
    var state: CompletionState {
        guard let currentUserId = currentUserId else {
            return .neither
        }
        return habit.completionState(on: selectedDate, currentUserId: currentUserId, buddyId: nil)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Text(habit.icon)
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.custom.text)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.title)
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                Text(habit.frequency.readableDescription)
                    .font(.customAppFont(size: 12, weight: .medium))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            ZStack {
                if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    Button {
                        updateCompletion()
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        ZStack{
                            Circle()
                                .fill(Color.custom.lightGrey)
                            
                            ZStack {
                                if state == .both || state == .me {
                                    Image(systemName: "checkmark")
                                        .font(.mySubtitle)
                                        .foregroundStyle(Color.custom.primary)
                                }else{
                                    Circle()
                                        .stroke(lineWidth: 1.2)
                                        .fill(Color.custom.text)
                                }
                            }.padding(15)
                        }
                    }
                }
            }.frame(height: 50)
            .padding(.vertical)
        }.padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.custom.grey)
        )
    }
}
