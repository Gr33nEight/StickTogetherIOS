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
    var content: String
    var date: Date
    var isRead: Bool = false
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
