//
//  NotificationType.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//


enum NotificationType: Hashable, Codable {
    case systemMessage
    case friendMessage
    case habitInvite(habitId: String?)
    case friendRequest
    
    var value: Int {
        switch self {
        case .systemMessage: return 0
        case .friendMessage: return 1
        case .habitInvite: return 2
        case .friendRequest: return 3
        }
    }
    
    var payload: String? {
        switch self {
        case .systemMessage:
            nil
        case .friendMessage:
            nil
        case .habitInvite(let habitId):
            habitId
        case .friendRequest:
            nil
        }
    }
}
