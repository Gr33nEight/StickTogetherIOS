//
//  HabitCellTemplate.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/12/2025.
//
import SwiftUI

struct HabitCellTemplate: View {
    let icon: String
    let title: String
    let habitCellBackground: Color
    let strikethrough: Bool
    let showCompletionButton: Bool
    let completionButtonBackground: Color
    let showBuddyStatus: [HabitCellBuddyInfo]
    let showCheckmark: Bool
    let checkmarkColor: Color
    let completionButtonBorderColor: Color
    let updateCompletion: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.custom.text)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.myBody)
                    .strikethrough(strikethrough)
                    .foregroundStyle(Color.custom.text)

                if !showBuddyStatus.isEmpty {
                    HStack(spacing: 5) {
//                        Image(.user)
//                            .renderingMode(.template)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 15)
//                            .foregroundStyle(showBuddyStatus.first?.buddyStatusColor ?? .custom.text)

                        HStack(spacing: 6) {
                            ForEach(Array(showBuddyStatus.prefix(3))) { buddyInfo in
                                HStack(spacing: 4) {

                                    Text(buddyInfo.buddyName)
                                        .foregroundStyle(buddyInfo.buddyStatusColor)
                                        .lineLimit(1)

                                    if let badge = buddyInfo.showStatusBadge {
                                        ZStack {
                                            if badge != .invited {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(buddyInfo.buddyStatusColor)
                                                    .frame(width: 12, height: 12)
                                            }

                                            Image(systemName: badge.imageName)
                                            .font(.customAppFont(size: 8, weight: .bold))
                                            .foregroundStyle(buddyInfo.buddyBadgeColor)
                                        }
                                    }
                                }
                            }

                            if showBuddyStatus.count > 3 {
                                Text("+\(showBuddyStatus.count - 3)")
                                    .foregroundStyle(Color.custom.lightGrey)
                            }
                        }
                        .lineLimit(1)
                    }
                    .font(.customAppFont(size: 12, weight: .medium))
                }
            }.multilineTextAlignment(.leading)
            Spacer()
            if showCompletionButton {
                Button {
                    updateCompletion()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    ZStack {
                        completionButtonBackground
                        if showCheckmark {
                            Image(systemName: "checkmark")
                                .font(.myBody)
                                .foregroundStyle(checkmarkColor)
                        }
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 2)
                            .foregroundStyle(completionButtonBorderColor)
                    )
                }
            }
        }
        .padding()
        .background(habitCellBackground)
        .contentShape(Rectangle())
        .drawingGroup()
    }
}
