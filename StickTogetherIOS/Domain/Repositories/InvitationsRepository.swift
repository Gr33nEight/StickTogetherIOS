//
//  InvitationsRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

protocol InvitationsRepository {
    func sendInvitation(_ invitation: Invitation) async throws
    func deleteInvitation(byId id: String) async throws
    func listenToReceivedInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], Error>
    func listenToSentInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], Error>
}
