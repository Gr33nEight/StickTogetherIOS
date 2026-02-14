//
//  FirestoreClient.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import FirebaseFirestore

protocol FirestoreClient: Actor {
    func fetch<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        query: FirestoreQuery
    ) async throws -> [E.DTO]
    
    func fetchDocument<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID
    ) async throws -> E.DTO
    
    func setData<E: FirestoreEndpoint>(
        _ dto: E.DTO,
        for endpoint: E.Type,
        id: FirestoreDocumentID,
        merge: Bool
    ) throws
    
    func setData<E: FirestoreEndpoint>(
        _ dto: E.DTO,
        for endpoint: E.Type,
        id: FirestoreDocumentID,
    ) throws
    
    func delete<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID
    ) async throws
    
    func listen<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        query: FirestoreQuery
    ) -> AsyncThrowingStream<[E.DTO], Error>
}
