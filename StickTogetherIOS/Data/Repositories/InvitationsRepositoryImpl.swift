//
//  InvitationsRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

final class InvitationsRepositoryImpl: InvitationsRepository {
    private let firestoreClient: FirestoreClient
    private let firestoreTransactionClient: FirestoreTransactionClient
    
    init(firestoreClient: FirestoreClient, firestoreTransactionClient: FirestoreTransactionClient) {
        self.firestoreClient = firestoreClient
        self.firestoreTransactionClient = firestoreTransactionClient
    }
    
    func getInvitation(with id: String) async throws -> Invitation {
        let doc = try await firestoreClient.fetchDocument(InvitationEndpoint.self, id: FirestoreDocumentID(value: id))
        return InvitationMapper.toDomain(doc)
    }
    
    func sendInvitation(_ invitation: Invitation) async throws {
        let dto = InvitationMapper.toDTO(invitation)
        let docId = try await firestoreClient.create(dto, for: InvitationEndpoint.self)
        try await firestoreClient.setData(dto, for: InvitationEndpoint.self, id: docId, merge: false)
    }
    
    func deleteInvitation(byId id: String) async throws {
        try await firestoreClient.delete(InvitationEndpoint.self, id: FirestoreDocumentID(value: id))
    }
    
    func deleteInvitation(transactionContext: TransactionContext, byId id: String) throws {
        try firestoreTransactionClient.delete(InvitationEndpoint.self, id: FirestoreDocumentID(value: id), transactionContext: transactionContext)
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
    
    func invitationBetween(userA: String, userB: String) async throws -> [Invitation] {
        let query = FirestoreQuery()
            .isIn(.field("senderId"), [.string(userA), .string(userB)])
            .isIn(.field("receiverId"), [.string(userA), .string(userB)])
        let dtos = try await firestoreClient.fetch(InvitationEndpoint.self, query: query)
        
        return dtos.map(InvitationMapper.toDomain(_:))
    }
}
