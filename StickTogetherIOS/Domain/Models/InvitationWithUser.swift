//
//  InvitationWithUser.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

struct InvitationWithUser: Identifiable {
    let invitation: Invitation
    let user: User
    
    var id: String {
        invitation.id ?? UUID().uuidString
    }
}
