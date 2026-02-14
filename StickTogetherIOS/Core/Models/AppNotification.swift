//
//  AppNotification.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/12/2025.
//
import SwiftUI
import FirebaseFirestore

struct AppNotification: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var senderId: String
    var receiverId: String
    var title: String
    var content: String
    var date: Date
    var isRead: Bool = false
    var type: AppNotificationType
    var habitId: String?
}

extension AppNotification {
    var dateString: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: date, relativeTo: Date())
    }
}

extension AppNotification {

    // MARK: - Habit invite (receiver side)

    static func habitInvite(
        senderId: String,
        receiverId: String,
        senderName: String,
        habitId: String?,
        habitTitle: String,
        habitIcon: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: "\(senderName.capitalized)",
            content: "Invited you to join a habit: \(habitTitle) \(habitIcon)",
            date: Date(),
            isRead: false,
            type: .habitInvite,
            habitId: habitId
        )
    }

    // MARK: - Buddy accepted invitation (system message)

    static func habitInviteAccepted(
        senderId: String,
        receiverId: String,
        senderName: String,
        habitId: String?,
        habitTitle: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: senderName.capitalized,
            content: "Accepted your invitation to \"\(habitTitle)\"",
            date: Date(),
            isRead: false,
            type: .systemMessage,
            habitId: habitId
        )
    }

    // MARK: - Habit removed (system message)

    static func habitRemoved(
        senderId: String,
        receiverId: String,
        senderName: String,
        habitId: String?,
        habitTitle: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: "TODO!",
            content: "\(senderName) removed the habit \"\(habitTitle)\"",
            date: Date(),
            isRead: false,
            type: .systemMessage,
            habitId: habitId
        )
    }

    // MARK: - Encouragement (friend message)

    static func encouragement(
        senderId: String,
        receiverId: String,
        senderName: String,
        habitId: String?,
        content: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: senderName.capitalized,
            content: content ,
            date: Date(),
            isRead: false,
            type: .friendMessage,
            habitId: habitId
        )
    }

    // MARK: - Buddy completed habit (friend message)

    static func buddyCompletedHabit(
        senderId: String,
        receiverId: String,
        senderName: String,
        habitId: String?,
        habitTitle: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: senderName.capitalized,
            content: "Completed \"\(habitTitle)\" today",
            date: Date(),
            isRead: false,
            type: .friendMessage,
            habitId: habitId
        )
    }
    
    static func habitInviteDeclined(
            senderId: String,
            receiverId: String,
            senderName: String,
            habitId: String?,
            habitTitle: String
        ) -> AppNotification {
            AppNotification(
                senderId: senderId,
                receiverId: receiverId,
                title: senderName.capitalized,
                content: "Declined your invitation to \"\(habitTitle)\"",
                date: Date(),
                isRead: false,
                type: .systemMessage,
                habitId: habitId
            )
        }
    
    static func friendRequestReceived(
        senderId: String,
        receiverId: String,
        senderName: String
    ) -> AppNotification {
        AppNotification(
            senderId: senderId,
            receiverId: receiverId,
            title: senderName.capitalized,
            content: "Sent you a friend request",
            date: Date(),
            isRead: false,
            type: .friendRequest,
            habitId: nil
        )
    }
}
