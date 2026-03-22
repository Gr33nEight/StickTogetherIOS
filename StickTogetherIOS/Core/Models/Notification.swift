//
//  Notification.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

import SwiftUI

struct Notification: Identifiable {
    var id: String?
    var receiverId: String
    var title: String
    var body: String
    var date: Date
    var isRead: Bool = false
    var type: NotificationType
}
