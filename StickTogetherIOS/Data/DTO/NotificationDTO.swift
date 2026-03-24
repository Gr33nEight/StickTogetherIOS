//
//  NotificationDTO.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

import Foundation
import FirebaseFirestore

struct NotificationDTO: Codable, Equatable {
    @DocumentID var id: String? = nil
    var senderId: String
    var receiverId: String
    var title: String
    var body: String
    var date: Date
    var isRead: Bool = false
    var payload: [String: String]?
    var type: Int
}
