//
//  InvitationDTO.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import FirebaseFirestore
import Foundation

struct InvitationDTO: Codable, Equatable {
    @DocumentID var id: String? = nil
    var senderId: String
    var receiverId: String
}
