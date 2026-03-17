//
//  FirestoreHelpers.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import FirebaseFirestore

struct FirestoreDocumentID {
    var value: String
}

enum FirestoreFilter {
    case isEqual(field: FirestoreField, value: FirestoreValue)
    case arrayContains(field: FirestoreField, value: FirestoreValue)
    case greaterThan(field: FirestoreField, value: FirestoreValue)
    case lessThan(field: FirestoreField, value: FirestoreValue)
    case isIn(field: FirestoreField, values: [FirestoreValue])
}

enum FirestoreField {
    case field(String)
    case documentId
}

enum FirestoreUpdateOperations {
    case set(Any)
    case union([Any])
    case remove([Any])
}

enum FirestoreValue {
    case string(String)
    case int(Int)
    case bool(Bool)
    case date(Date)
}

enum FirestoreError: Error {
    case unknown
}

extension FirestoreValue {
    var raw: Any {
        switch self {
        case .string(let string):
            return string
        case .int(let int):
            return int
        case .bool(let bool):
            return bool
        case .date(let date):
            return Timestamp(date: date)
        }
    }
}
