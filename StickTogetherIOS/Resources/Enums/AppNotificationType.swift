//
//  AppNotificationType.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/12/2025.
//


import SwiftUI

enum AppNotificationType: String, Hashable, Codable {
    case systemMessage
    case friendMessage
    case habitInvite
    case friendRequest
}
