//
//  FirestoreTransactionImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation
import FirebaseFirestore

final class FirestoreTransactionImpl: FirestoreTransaction {
    private let transaction: FirebaseFirestore.Transaction
    private let db: Firestore
    
    init(transaction: FirebaseFirestore.Transaction, db: Firestore) {
        self.transaction = transaction
        self.db = db
    }
    
    func update<E>(_ endpoint: E.Type, id: FirestoreDocumentID, data: [String : FirestoreUpdateOperations]) throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        transaction.updateData(FirestoreUpdateOperationsMapper.toUpdateData(data), forDocument: ref)
    }
    
    func delete<E>(_ endpoint: E.Type, id: FirestoreDocumentID) throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        transaction.deleteDocument(ref)
    }
}
