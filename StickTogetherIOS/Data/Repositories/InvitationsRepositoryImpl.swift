//
//  InvitationsRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

final class InvitationsRepositoryImpl: InvitationsRepository {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func sendInvitation(_ invitation: Invitation) async throws {
        let dto = InvitationMapper.toDTO(invitation)
        guard let dtoId = dto.id else {
            throw FirestoreError.unknown
        }
        let docId = FirestoreDocumentID(value: dtoId)
        try firestoreClient.setData(dto, for: InvitationEndpoint.self, id: docId, merge: false)
    }
    
    func deleteInvitation(byId id: String) async throws {
        try await firestoreClient.delete(InvitationEndpoint.self, id: FirestoreDocumentID(value: id))
    }
    
    func listenToReceivedInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], any Error> {
        let query = FirestoreQuery().isEqual(.field("receiverId"), .string(userId))
        let stream = firestoreClient.listen(InvitationEndpoint.self, query: query)
        return InvitationMapper.invitationStream(stream)
    }
    
    func listenToSentInvitations(for userId: String) -> AsyncThrowingStream<[Invitation], any Error> {
        let query = FirestoreQuery().isEqual(.field("senderId"), .string(userId))
        let stream = firestoreClient.listen(InvitationEndpoint.self, query: query)
        return InvitationMapper.invitationStream(stream)
    }
}
