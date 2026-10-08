//
//  FirestoreClientImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//
import FirebaseFirestore
import Foundation

/// Serializes updates from the concurrent per-chunk listener tasks.
private final class ChunkedListenerState<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var latestByChunk: [Int: [Value]] = [:]

    func update(
        _ values: [Value],
        for chunk: Int,
        publish: ([Value]) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }

        latestByChunk[chunk] = values
        publish(latestByChunk.values.flatMap { $0 })
    }
}

final class FirestoreClientImpl: FirestoreClient {
    private let db: Firestore
    private let responseCache = FirestoreResponseCache.shared
    
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    func fetch<E>(
        _ endpoint: E.Type,
        query: FirestoreQuery
    ) async throws -> [E.DTO] where E : FirestoreEndpoint {
        let cacheKey = "\(E.path)|query|\(query.cacheKey)"
        if let cached: [E.DTO] = responseCache.value(for: cacheKey, as: [E.DTO].self) {
            return cached
        }
        do {
            let snapshot = try await self.fetchSnapshot(endpoint, query: query)
            let values = try snapshot.documents.compactMap {
                try $0.data(as: E.DTO.self)
            }
            responseCache.store(values, for: cacheKey)
            return values
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func fetchDocument<E>(_ endpoint: E.Type, id: FirestoreDocumentID) async throws -> E.DTO where E : FirestoreEndpoint{
        let cacheKey = "\(E.path)|document|\(id.value)"
        if let cached: E.DTO = responseCache.value(for: cacheKey, as: E.DTO.self) {
            return cached
        }
        let snapshot: DocumentSnapshot
        do {
            snapshot = try await db.collection(endpoint.path).document(id.value).getDocument()
        } catch {
            throw FirestoreErrorMapper.map(error)
        }

        guard snapshot.exists else {
            throw FirestoreClientError.documentNotFound
        }

        do {
            let value = try snapshot.data(as: E.DTO.self)
            responseCache.store(value, for: cacheKey)
            return value
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }

    func fetchDocumentFromServer<E>(_ endpoint: E.Type, id: FirestoreDocumentID) async throws -> E.DTO where E : FirestoreEndpoint {
        let snapshot: DocumentSnapshot
        do {
            snapshot = try await db.collection(endpoint.path)
                .document(id.value)
                .getDocument(source: .server)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }

        guard snapshot.exists else {
            throw FirestoreClientError.documentNotFound
        }

        do {
            return try snapshot.data(as: E.DTO.self)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func setData<E>(_ dto: E.DTO, for endpoint: E.Type, id: FirestoreDocumentID, merge: Bool) async throws where E : FirestoreEndpoint {
        let doc = db.collection(endpoint.path).document(id.value)
        do {
            try await doc.setData(from: dto, merge: merge)
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func setData<E>(_ dto: E.DTO, for endpoint: E.Type, id: FirestoreDocumentID) async throws where E : FirestoreEndpoint {
        let doc = db.collection(endpoint.path).document(id.value)
        do {
            try await doc.setData(from: dto)
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func updateData<E>(for endpoint: E.Type, id: FirestoreDocumentID, _ fields: [String : FirestoreUpdateOperations]) async throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        let data = FirestoreUpdateOperationsMapper.toUpdateData(fields)
        
        do {
            try await ref.updateData(data)
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    
    func delete<E>(_ endpoint: E.Type, id: FirestoreDocumentID) async throws where E : FirestoreEndpoint {
        let ref = db.collection(endpoint.path).document(id.value)
        do {
            try await ref.delete()
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func batchDelete<E>(_ endpoint: E.Type, query: FirestoreQuery) async throws where E : FirestoreEndpoint {
        do {
            let snapshot = try await self.fetchSnapshot(endpoint, query: query)
            let batch = db.batch()
            
            for doc in snapshot.documents {
                batch.deleteDocument(doc.reference)
            }
            
            try await batch.commit()
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
    
    func listen<E>(_ endpoint: E.Type, query: FirestoreQuery) -> AsyncThrowingStream<[E.DTO], any Error> where E : FirestoreEndpoint {
        AsyncThrowingStream { continuation in
            var ref: Query = db.collection(endpoint.path)
            
            for filter in query.filters {
                ref = applyFilter(ref, filter: filter)
            }
            
            if let order = query.order {
                ref = ref.order(by: order.field, descending: order.descending)
            }
            
            if let limit = query.limit {
                ref = ref.limit(to: limit)
            }
            
            let listener = ref.addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: FirestoreErrorMapper.map(error))
                    return
                }
                
                guard let snapshot else { return }
                self.responseCache.invalidate(endpoint: E.path)
                
                do {
                    let data = try snapshot.documents.map {
                        try $0.data(as: E.DTO.self)
                    }
                    continuation.yield(data)
                } catch {
                    continuation.finish(throwing: FirestoreErrorMapper.map(error))
                    return
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func listenDocument<E>(_ endpoint: E.Type, id: FirestoreDocumentID) -> AsyncThrowingStream<E.DTO, any Error> where E : FirestoreEndpoint {
        return AsyncThrowingStream { continuation in
            let listener = db.collection(endpoint.path).document(id.value).addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: FirestoreErrorMapper.map(error))
                    return
                }
                
                guard let snapshot else { return }
                self.responseCache.invalidate(endpoint: E.path)
                
                
                guard snapshot.exists else {
                    continuation.finish(
                        throwing: FirestoreClientError.documentNotFound
                    )
                    return
                }
                
                do {
                    let data = try snapshot.data(as: E.DTO.self)
                    continuation.yield(data)
                } catch {
                    continuation.finish(throwing: FirestoreErrorMapper.map(error))
                    return
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func create<E: FirestoreEndpoint>(
        _ dto: E.DTO,
        for endpoint: E.Type
    ) async throws -> FirestoreDocumentID {
        
        let ref = db.collection(endpoint.path).document()
        
        do {
            try await ref.setData(from: dto)
            responseCache.invalidate(endpoint: E.path)
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
        
        return FirestoreDocumentID(value: ref.documentID)
    }
    
    func runTransaction(_ block: @escaping (TransactionContext) throws -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.runTransaction({ transaction, errorPointer -> Any? in
                let context = TransactionContext(transaction: transaction)
                do {
                    try block(context)
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }) { _, error in
                if let error {
                    continuation.resume(throwing: FirestoreErrorMapper.map(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func listenChunked<E>(
        _ endpoint: E.Type,
        chunks: [[String]],
        queryBuilder: @escaping ([String]) -> FirestoreQuery
    ) -> AsyncThrowingStream<[E.DTO], Error> where E: FirestoreEndpoint {
        
        return AsyncThrowingStream { continuation in
            var tasks: [Task<Void, Never>] = []
            let state = ChunkedListenerState<E.DTO>()
            
            for (index, chunk) in chunks.enumerated() {
                let query = queryBuilder(chunk)
                
                let stream = self.listen(endpoint, query: query)
                
                let task = Task {
                    do {
                        for try await dtos in stream {
                            state.update(dtos, for: index) { merged in
                                continuation.yield(merged)
                            }
                        }
                    } catch {
                        continuation.finish(throwing: FirestoreErrorMapper.map(error))
                    }
                }
                
                tasks.append(task)
            }
            
            continuation.onTermination = { @Sendable _ in
                tasks.forEach { $0.cancel() }
            }
        }
    }
    
    private func applyFilter(
        _ ref: Query,
        filter: FirestoreFilter
    ) -> Query {
        
        switch filter {
            
        case .isEqual(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, isEqualTo: value.raw) },
                documentIdBlock: { $0.whereField($1, isEqualTo: value.raw) }
            )
            
        case .arrayContains(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, arrayContains: value.raw) },
                documentIdBlock: { $0.whereField($1, arrayContains: value.raw) }
            )
            
        case .greaterThan(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, isGreaterThan: value.raw) },
                documentIdBlock: { $0.whereField($1, isGreaterThan: value.raw) }
            )
            
        case .greaterThanOrEqualTo(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, isGreaterThanOrEqualTo: value.raw) },
                documentIdBlock: { $0.whereField($1, isGreaterThanOrEqualTo: value.raw) }
            )
            
        case .lessThan(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, isLessThan: value.raw) },
                documentIdBlock: { $0.whereField($1, isLessThan: value.raw) }
            )
            
        case .lessThanOrEqualTo(let field, let value):
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, isLessThanOrEqualTo: value.raw) },
                documentIdBlock: { $0.whereField($1, isLessThanOrEqualTo: value.raw) }
            )

            
        case .isIn(let field, let values):
            let rawValues = values.map { $0.raw }
            
            return apply(
                ref,
                field: field,
                stringBlock: { $0.whereField($1, in: rawValues) },
                documentIdBlock: { $0.whereField($1, in: rawValues) }
            )
        }
    }
    
    private func apply(
        _ ref: Query,
        field: FirestoreField,
        stringBlock: (Query, String) -> Query,
        documentIdBlock: (Query, FieldPath) -> Query
    ) -> Query {
        
        switch field {
        case .field(let name):
            return stringBlock(ref, name)
            
        case .documentId:
            return documentIdBlock(ref, FieldPath.documentID())
        }
    }
    
    private func fetchSnapshot<E>(_ endpoint: E.Type, query: FirestoreQuery) async throws -> QuerySnapshot where E: FirestoreEndpoint {
        var ref: Query = db.collection(endpoint.path)
        
        for filter in query.filters {
            ref = applyFilter(ref, filter: filter)
        }
        
        if let order = query.order {
            ref = ref.order(by: order.field, descending: order.descending)
        }
        
        if let limit = query.limit {
            ref = ref.limit(to: limit)
        }
        
        do {
            return try await ref.getDocuments()
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
}
