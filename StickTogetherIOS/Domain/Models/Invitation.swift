//
//  Invitation.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//

import Foundation

struct Invitation: Codable, Identifiable {
    var id: String? = nil
    var senderId: String
    var receiverId: String
}
