//
//  Notification.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

import SwiftUI

struct Notification: Identifiable {
    var id: String?
    var senderId: String
    var receiverId: String
    var title: String
    var body: String
    var date: Date = Date()
    var isRead: Bool = false
    var type: NotificationType
}

extension Notification {
    var dateString: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: date, relativeTo: Date())
    }
}
