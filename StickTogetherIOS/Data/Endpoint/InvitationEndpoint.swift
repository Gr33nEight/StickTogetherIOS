//
//  InvitationEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

enum InvitationEndpoint: FirestoreEndpoint {
    typealias DTO = InvitationDTO
    
    static var path: String = "invitations"
}
