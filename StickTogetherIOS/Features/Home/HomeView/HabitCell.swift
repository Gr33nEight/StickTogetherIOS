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
    let buddy: User?
    let currentUserId: String?
    
    var state: CompletionState {
        guard let currentUserId = currentUserId else {
            return .neither
        }
        return habit.completionState(on: selectedDate, currentUserId: currentUserId, buddyId: habit.buddyId)
    }
    
    var isDone: Bool { state == .both || state == .me }
    var buddyDid: Bool { state == .both || state == .buddy }
    
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
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.myBody)
                    .strikethrough(isDone)
                    .foregroundStyle(Color.custom.text)
                HStack(spacing: 5) {
                    if let buddyName = buddy?.name {
                        Image(.user)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                        Text(buddyName)
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(buddyDid ? Color.custom.primary : Color.custom.red)
                                .frame(width: 12, height: 12)
                            Image(systemName: buddyDid ? "checkmark" : "xmark")
                                .foregroundStyle(Color.custom.text)
                                .font(.customAppFont(size: 8, weight: .bold))
                        }.padding(.leading, 2)
                    }
                }.font(.customAppFont(size: 12, weight: .medium))
                    .foregroundStyle(buddyDid ? Color.custom.primary : Color.custom.red)
            }.multilineTextAlignment(.leading)
            Spacer()
            if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                Button {
                    updateCompletion()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    ZStack {
                        if isDone {
                            Color.custom.primary
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.custom.text)
                                .font(.myBody)
                        }else{
                            Color.custom.grey
                        }
                    }.frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 2)
                            .fill(isDone ? Color.custom.primary : Color(.systemGray))
                    )
                }
            }
        }.padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.custom.grey)
        )
    }
}

#Preview {
    ZStack {
        Color.custom.background
        HabitCell(habit: Habit(title: "Eat Healthy Food", icon: "🔥", ownerId: "", frequency: Frequency(type: .monthly)), updateCompletion: {
            
        }, selectedDate: Date(), buddy: User(name: "Natanael", email: ""), currentUserId: "")
        .padding()
    }
    .preferredColorScheme(.dark)
}
