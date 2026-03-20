//
//  FirestoreTransactionImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//

import Foundation
import FirebaseFirestore

final class FirestoreTransactionClientImpl: FirestoreTransactionClient {
    private let db: Firestore
    
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    func update<E>(_ endpoint: E.Type, id: FirestoreDocumentID, data: [String : FirestoreUpdateOperations], transactionContext: TransactionContext) throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        let data = FirestoreUpdateOperationsMapper.toUpdateData(data)
        
        transactionContext.transaction.updateData(data, forDocument: ref)
    }
    
    func delete<E>(_ endpoint: E.Type, id: FirestoreDocumentID, transactionContext: TransactionContext) throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        transactionContext.transaction.deleteDocument(ref)
    }
}
