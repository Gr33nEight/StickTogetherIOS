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

enum FirestoreFilterOperator {
    case isEqualTo
    case arrayContains
    case greaterThan
    case lessThan
}

struct FirestoreFilter {
    let field: String
    let op: FirestoreFilterOperator
    let value: FirestoreValue
}

enum FirestoreValue {
    case string(String)
    case int(Int)
    case bool(Bool)
    case date(Date)
}

enum HabitEndpoint: FirestoreEndpoint {
    typealias DTO = HabitDTO
    static var path = "habits"
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
