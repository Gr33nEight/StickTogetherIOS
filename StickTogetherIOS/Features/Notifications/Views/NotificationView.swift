//
//  NotificationView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 03/12/2025.
//

import SwiftUI

struct AppNotification: Hashable {
    var senderId: String
    var receiverId: String
    var content: String
    var date: Date
    var isRead: Bool
    var type: AppNotificationType
    var payload: [String: String]
}

extension AppNotification {
    var dateString: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: date, relativeTo: Date())
    }
}

enum AppNotificationType: String, Hashable {
    case systemMessage
    case friendMessage
    case habitInvite
}

struct NotificationView: View {
    @State var removingStarted: Bool = false
    @State var dummyNotifications: [AppNotification] = [
        // 1. System message
        AppNotification(
            senderId: "system",
            receiverId: "user_123",
            content: "Welcome to StickTogether! Let's build habits together 💪",
            date: Date().addingTimeInterval(-3600),
            isRead: false,
            type: .systemMessage,
            payload: [:]
        ),
        
        // 2. Friend message
        AppNotification(
            senderId: "user_456",
            receiverId: "user_123",
            content: "Hey! I completed my habit today, did you? 😄",
            date: Date().addingTimeInterval(-7200),
            isRead: true,
            type: .friendMessage,
            payload: [
                "friendName": "Marek"
            ]
        ),
        
        // 3. Habit invite
        AppNotification(
            senderId: "user_789",
            receiverId: "user_123",
            content: "Anna invited you to join her habit: 'Morning Run' 🏃‍♂️",
            date: Date().addingTimeInterval(-300),
            isRead: false,
            type: .habitInvite,
            payload: [
                "habitId": "habit_001",
            ]
        )
    ]
    var body: some View {
        CustomView(title: "Notifications") {
            ScrollView {
                VStack {
                    ForEach(dummyNotifications, id:\.self) { notification in
                        NotificationCell(notification: notification)
                            .onTapGesture {
                                // isRead = false
                            }
                    }
                }.padding()
            }
        } buttons: {
            Button(action: {}, label: {
                Text("Mark all as read")
            })
                .customButtonStyle(.primary)
        } icons: {
            Button {
                removingStarted.toggle()
            } label: {
                Image(.trash)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .tint(removingStarted ? Color.custom.red : Color.custom.primary)
            }

        }

    }
}

struct NotificationCell: View {
    let notification: AppNotification
    var body: some View {
        switch notification.type {
        case .systemMessage:
            SystemMessageCell(notification: notification)
            
        case .friendMessage:
            FriendMessageCell(notification: notification)
            
        case .habitInvite:
            HabitInviteCell(notification: notification)
        }
    }
}

struct SystemMessageCell: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(.logoLight)
                .resizable()
                .scaledToFit()
                .frame(width: 52)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 5)
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.content)
                    .font(.customAppFont(size: 13, weight: .bold))
                    .foregroundStyle(Color.custom.text)
                Text(notification.dateString)
                    .font(.customAppFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            if !notification.isRead {
                Circle()
                    .fill(Color.custom.primary)
                    .frame(width: 8)
            }
        }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(notification.isRead ? Color.custom.background : Color.custom.grey)
                )
    }
}
struct FriendMessageCell: View {
    let notification: AppNotification
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("🙍‍♂️")
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color.custom.text)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.content)
                    .font(.customAppFont(size: 13, weight: .bold))
                    .foregroundStyle(Color.custom.text)
                Text(notification.dateString)
                    .font(.customAppFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            if !notification.isRead {
                Circle()
                    .fill(Color.custom.primary)
                    .frame(width: 8)
            }
        }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(notification.isRead ? Color.custom.background : Color.custom.grey)
                )
    }
}
struct HabitInviteCell: View {
    let notification: AppNotification
    
    private var dateString: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: notification.date, relativeTo: Date())
    }

    var body: some View {
        VStack{
            HStack(spacing: 15) {
                Text("🙍‍♂️")
                    .font(.system(size: 23))
                    .shadow(color: .black.opacity(0.5), radius: 5)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.custom.text)
                    )
                VStack(alignment: .leading, spacing: 3) {
                    Text(notification.content)
                        .font(.customAppFont(size: 13, weight: .bold))
                        .foregroundStyle(Color.custom.text)
                    Text(notification.dateString)
                        .font(.customAppFont(size: 12, weight: .regular))
                        .foregroundStyle(Color.custom.primary)
                }.multilineTextAlignment(.leading)
                Spacer()
                if !notification.isRead {
                    Circle()
                        .fill(Color.custom.primary)
                        .frame(width: 8)
                }
            }
            HStack(spacing: 10) {
                Button {
//                    accept()
                } label: {
                    Text("Accept")
                        .padding(-8)
                }.customButtonStyle(.primary)
                Button {
//                    decline()
                } label: {
                    Text("Decline")
                        .padding(-8)
                }.customButtonStyle(.secondary)
            }.padding(.top)
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(notification.isRead ? Color.custom.background : Color.custom.grey)
            )
    }
}



#Preview {
    NotificationView()
        .preferredColorScheme(.dark)
}
