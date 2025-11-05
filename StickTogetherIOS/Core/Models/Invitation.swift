//
//  Invitation.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//

import Foundation
import FirebaseFirestore

struct Invitation: Codable, Identifiable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
}
