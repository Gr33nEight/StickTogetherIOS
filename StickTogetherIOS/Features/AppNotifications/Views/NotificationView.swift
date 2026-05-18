//
//  NotificationView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 03/12/2025.
//

import SwiftUI

struct NotificationView: View {
    @State var removingStarted: Bool = false
    @EnvironmentObject var notificationVM: NotificationsViewModel
    var body: some View {
        CustomView(title: "Notifications") {
            ZStack {
                if notificationVM.userNotifications.isEmpty {
                    Text("You don't have any notifications.")
                        .foregroundStyle(Color.custom.lightGrey)
                        .font(.mySubtitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }else{
                    ScrollView {
                        VStack {
                            ForEach(notificationVM.userNotifications, id:\.id) { notification in
                                NotificationCell(notification: notification)
                                    .onTapGesture {
                                        Task {
                                            await notificationVM.markAsRead(notification.id)
                                        }
                                    }
                            }
                        }.padding()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } buttons: {
            if !notificationVM.userNotifications.isEmpty {
                Button("Mark all as read"){
                    Task {
                        await notificationVM.markAllAsRead()
                    }
                }.customButtonStyle(.primary)
            }
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
    let notification: Notification
    var body: some View {
        switch notification.type {
        case .systemMessage:
            SystemMessageCell(notification: notification)
            
        case .friendMessage:
            FriendMessageCell(notification: notification)
            
        case .habitInvite:
            HabitInviteCell(notification: notification)
        
        case .friendRequest:
            EmptyView()
        }
    }
}

struct SystemMessageCell: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(.logoLight)
                .resizable()
                .scaledToFit()
                .frame(width: 52)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 5)
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.body)
                    .font(.customAppFont(size: 13, weight: .bold))
                    .foregroundStyle(Color.custom.text)
                Text(notification.dateString)
                    .font(.customAppFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            if !notification.isRead {
                HStack(alignment: .center) {
                    Circle()
                        .fill(Color.custom.red)
                        .frame(width: 8)
                }.frame(maxHeight: .infinity)
            }
        }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(notification.isRead ? Color.custom.background : Color.custom.grey)
                )
    }
}
struct FriendMessageCell: View {
    let notification: Notification
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
                Text(notification.body)
                    .font(.customAppFont(size: 13, weight: .bold))
                    .foregroundStyle(Color.custom.text)
                Text(notification.dateString)
                    .font(.customAppFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
            if !notification.isRead {
                HStack(alignment: .center) {
                    Circle()
                        .fill(Color.custom.red)
                        .frame(width: 8)
                }.frame(maxHeight: .infinity)
            }
        }.padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(notification.isRead ? Color.custom.background : Color.custom.grey)
                )
    }
}
struct HabitInviteCell: View {
    @EnvironmentObject var notificationsVM: NotificationsViewModel
    @State var habit: Habit? = nil
    
    let notification: Notification
    
    private var dateString: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: notification.date, relativeTo: Date())
    }

    var body: some View {
        ZStack {
            if habit != nil {
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
                            Text(notification.body)
                                .font(.customAppFont(size: 13, weight: .bold))
                                .foregroundStyle(Color.custom.text)
                            Text(notification.dateString)
                                .font(.customAppFont(size: 12, weight: .regular))
                                .foregroundStyle(Color.custom.primary)
                        }.multilineTextAlignment(.leading)
                        Spacer()
                        if !notification.isRead {
                            HStack(alignment: .center) {
                                Circle()
                                    .fill(Color.custom.red)
                                    .frame(width: 8)
                            }.frame(maxHeight: .infinity)
                        }
                    }
                    HStack(spacing: 10) {
                        Button {
                            Task {
                                await notificationsVM.acceptInviation(notificationId: notification.id, habit: habit)
                            }
                        } label: {
                            Text("Accept")
                                .padding(-8)
                        }.customButtonStyle(.primary)
                        Button {
                            Task {
                                await notificationsVM.declineInvitation(notificationId: notification.id, habit: habit)
                            }
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
        }.task {
            guard let habitId = notification.type.payload else { return }
            habit = await notificationsVM.getHabitBy(id: habitId)
        }
    }
}



#Preview {
    NotificationView()
        .preferredColorScheme(.dark)
}
