//
//  FirestoreTransactionFactory.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 20/03/2026.
//
import SwiftUI

final class FirestoreTransactionFactory: TransactionFactory {
    private let client: FirestoreClient
    
    init(client: FirestoreClient) {
        self.client = client
    }
    
    func run(_ block: @escaping (TransactionContext) throws -> Void) async throws {
        try await client.runTransaction { transactionalClient in
            try block(transactionalClient)
        }
    }
}
