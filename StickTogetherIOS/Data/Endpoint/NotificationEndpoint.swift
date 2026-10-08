//
//  NotificationEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

enum NotificationEndpoint: FirestoreEndpoint {
    typealias DTO = NotificationDTO
    static var path: String = "notifications"
}
