//
//  InvitationsRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

protocol InvitationsRepository {
    func getInvitation(with invitationId: String) async throws -> Invitation
    func sendInvitation(_ invitation: Invitation) async throws
    func deleteInvitation(byId id: String) async throws
    func deleteInvitation(transactionContext: TransactionContext, byId id: String) throws
    func listenToReceivedInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], Error>
    func listenToSentInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], Error>
    func invitationBetween(userA: String, userB: String) async throws -> [Invitation]
}
