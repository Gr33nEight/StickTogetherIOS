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
    let updateCompletion: () -> Void
    let selectedDate: Date
    let buddy: User?

    private var completionState: CompletionState {
        habit.completionState(
            on: selectedDate,
            currentUserId: profileVM.safeUser.safeID,
            ownerId: habit.ownerId,
            buddyId: habit.buddyId
        )
    }

    private var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }

    private var iDid: Bool {
        buddy == nil ? completionState == .both : completionState == .me
    }

    private var buddyDid: Bool {
        guard buddy != nil else { return false }
        return completionState == .both || completionState == .buddy
    }

    private var done: Bool {
        completionState == .both
    }

    private var buddyColor: Color {
        if done || isPastAndNotDone { return Color.custom.text }
        return buddyDid ? Color.custom.primary : Color.custom.red
    }
    
    private var isPastAndNotDone: Bool {
        selectedDate < Calendar.current.startOfDay(for: Date()) && !done
    }
    
    private var isPreview: Bool { habit.type == .preview }
    private var iAmBuddy: Bool { habit.buddyId == profileVM.safeUser.safeID }

    var body: some View {
        HStack(spacing: 15) {
            iconView
            contentView
            Spacer()
            
            let isPreview = habit.type == .preview
            let iAmBuddy = habit.buddyId == profileVM.safeUser.safeID

            if isToday && (!isPreview || !iAmBuddy) {
                completionButton
            }
        }
        .padding()
        .background(cardBackground)
        .contentShape(Rectangle())
        .drawingGroup()
    }
}

private extension HabitCell {
    var iconView: some View {
        Text(habit.icon)
            .font(.system(size: 23))
            .shadow(color: .black.opacity(0.5), radius: 5)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.custom.text)
            )
    }
}

private extension HabitCell {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.title)
                .font(.myBody)
                .strikethrough(iDid || done)
                .foregroundStyle(Color.custom.text)

            if habit.type == .coop || (habit.type == .preview && habit.buddyId == profileVM.safeUser.safeID) {
                buddyStatusView
            }
        }
        .multilineTextAlignment(.leading)
    }
}

private extension HabitCell {
    var buddyStatusView: some View {
        HStack(spacing: 5) {
            Image(.user)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15)
                .foregroundStyle(buddy == nil ? Color.custom.text : (!isPreview || !iAmBuddy) ? buddyColor : Color.custom.text)

            if let buddyName = buddy?.name {
                Text(buddyName)
                    .foregroundStyle((!isPreview || !iAmBuddy) ? buddyColor : Color.custom.text)

                if (!isPreview || !iAmBuddy) { statusBadge }
            } else {
                Text("Waiting for response")
                    .foregroundStyle(Color.custom.text)
            }
        }
        .font(.customAppFont(size: 12, weight: .medium))
    }

    var statusBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(buddyColor)
                .frame(width: 12, height: 12)

            Image(systemName: buddyDid ? "checkmark" : "xmark")
                .font(.customAppFont(size: 8, weight: .bold))
                .foregroundStyle(done || isPastAndNotDone ? buddyDid ? Color.custom.primary : Color.custom.red : Color.custom.text)
        }
        .padding(.leading, 2)
    }
}
private extension HabitCell {
    var completionButton: some View {
        Button {
            updateCompletion()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            ZStack {
                completionButtonBackground
                if iDid || done {
                    Image(systemName: "checkmark")
                        .font(.myBody)
                        .foregroundStyle(done ? Color.custom.primary : Color.custom.text)
                }
            }
            .frame(width: 30, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(iDid || done ? .clear : Color(.systemGray))
            )
        }
    }

    var completionButtonBackground: Color {
        if done { return Color.custom.text }
        if iDid { return Color.custom.primary }
        return Color.custom.grey
    }
}

private extension HabitCell {
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(cardBackgroundColor)
    }
    
    var cardBackgroundColor: Color {
        if done {
            return Color.custom.primary
        }
        
        if habit.type == .preview {
            return buddyDid ? Color.custom.primary : Color.custom.red
        }
        
        if isPastAndNotDone {
            return Color.custom.red
        }
        
        return Color.custom.grey
    }
}

#Preview {
    ZStack {
        Color.custom.background
        HabitCell(habit: Habit(title: "Eat Healthy Food", icon: "🔥", ownerId: "", frequency: Frequency(type: .monthly)), updateCompletion: {
            
        }, selectedDate: Date(), buddy: User(name: "Natanael", email: ""))
        .padding()
    }

    .preferredColorScheme(.dark)
    .environmentObject(ProfileViewModel(profileService: MockProfileService())
    )
}
