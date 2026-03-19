//
//  FirestoreTransaction.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol FirestoreTransaction {
    func update<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID,
        data: [String: FirestoreUpdateOperations]
    ) throws
    
    func delete<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID
    ) throws
}
