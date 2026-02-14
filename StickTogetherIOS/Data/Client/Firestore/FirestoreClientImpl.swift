//
//  FirestoreClientImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//
import FirebaseFirestore
import Foundation

final class FirestoreClientImpl: FirestoreClient {
    private let db = Firestore.firestore()
    
    func fetch<E>(
        _ endpoint: E.Type,
        query: FirestoreQuery
    ) async throws -> [E.DTO] where E : FirestoreEndpoint {
        var ref: Query = db.collection(endpoint.path)
        
        for filter in query.filters {
            switch filter.op {
            case .isEqualTo:
                ref = ref.whereField(filter.field, isEqualTo: filter.value.raw)
            case .arrayContains:
                ref = ref.whereField(filter.field, arrayContains: filter.value.raw)
            case .greaterThan:
                ref = ref.whereField(filter.field, isGreaterThan: filter.value.raw)
            case .lessThan:
                ref = ref.whereField(filter.field, isLessThan: filter.value.raw)
            }
        }
        
        if let order = query.order {
            ref = ref.order(by: order.field, descending: order.descending)
        }
        
        if let limit = query.limit {
            ref = ref.limit(to: limit)
        }
        
        let snapshot = try await ref.getDocuments()
        return snapshot.documents.compactMap {
            try? $0.data(as: E.DTO.self)
        }
    }
    
    func fetchDocument<E>(_ endpoint: E.Type, id: FirestoreDocumentID) async throws -> E.DTO where E : FirestoreEndpoint{
        return try await db.collection(endpoint.path).document(id.value).getDocument().data(as: E.DTO.self)
    }
    
     func setData<E>(_ dto: E.DTO, for endpoint: E.Type, id: FirestoreDocumentID, merge: Bool) throws where E : FirestoreEndpoint {
            let doc = db.collection(endpoint.path).document(id.value)
            try doc.setData(from: dto, merge: merge)
    }

    func setData<E>(_ dto: E.DTO, for endpoint: E.Type, id: FirestoreDocumentID) throws where E : FirestoreEndpoint {
           let doc = db.collection(endpoint.path).document(id.value)
           try doc.setData(from: dto)
    }
    
    
    func delete<E>(_ endpoint: E.Type, id: FirestoreDocumentID) async throws where E : FirestoreEndpoint {
        try await db.collection(endpoint.path).document(id.value).delete()
    }
    
    func listen<E>(_ endpoint: E.Type, query: FirestoreQuery) -> AsyncThrowingStream<[E.DTO], any Error> where E : FirestoreEndpoint {
        AsyncThrowingStream { continuation in
            var ref: Query = db.collection(endpoint.path)

            for filter in query.filters {
                switch filter.op {
                case .isEqualTo:
                    ref = ref.whereField(filter.field, isEqualTo: filter.value.raw)
                case .arrayContains:
                    ref = ref.whereField(filter.field, arrayContains: filter.value.raw)
                case .greaterThan:
                    ref = ref.whereField(filter.field, isGreaterThan: filter.value.raw)
                case .lessThan:
                    ref = ref.whereField(filter.field, isLessThan: filter.value.raw)
                }
            }

            if let order = query.order {
                ref = ref.order(by: order.field, descending: order.descending)
            }

            if let limit = query.limit {
                ref = ref.limit(to: limit)
            }
            
            let listener = ref.addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let snapshot else { return }
                
                do {
                    let data = try snapshot.documents.map {
                        try $0.data(as: E.DTO.self)
                    }
                    continuation.yield(data)
                } catch {
                    continuation.finish(throwing: error)
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
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let snapshot else { return }
                
                do {
                    let data = try snapshot.data(as: E.DTO.self)
                    continuation.yield(data)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
