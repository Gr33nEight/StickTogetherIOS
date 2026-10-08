//
//  FirestoreUpdateOperations.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation
import FirebaseFirestore

enum FirestoreUpdateOperationsMapper {
    static func toUpdateData(_ fields: [String: FirestoreUpdateOperations]) -> [AnyHashable : Any] {
        var mapped: [String: Any] = [:]
    
        for (key, op) in fields {
            switch op {
            case .set(let value):
                mapped[key] = value
            case .union(let values):
                mapped[key] = FieldValue.arrayUnion(values)
            case .remove(let values):
                mapped[key] = FieldValue.arrayRemove(values)
            }
        }
        
        return mapped
    }
}
