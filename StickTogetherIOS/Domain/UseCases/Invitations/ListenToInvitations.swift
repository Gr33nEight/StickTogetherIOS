//
//  ListenToInvitations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

protocol ListenToInvitations {
    func stream(for id: String) -> AsyncThrowingStream<[InvitationWithUser], any Error>
}
