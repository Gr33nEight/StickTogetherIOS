//
//  FirestoreTransaction.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation

protocol FirestoreTransactionClient {
    func update<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID,
        data: [String: FirestoreUpdateOperations],
        transactionContext: TransactionContext
    ) throws
    
    func delete<E: FirestoreEndpoint>(
        _ endpoint: E.Type,
        id: FirestoreDocumentID,
        transactionContext: TransactionContext
    ) throws
}
