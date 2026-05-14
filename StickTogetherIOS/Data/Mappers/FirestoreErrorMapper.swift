//
//  FirstoreErrorMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//

import SwiftUI
import FirebaseFirestore

enum FirestoreErrorMapper {
    static func map(_ error: Error) -> FirestoreClientError {
        let nsError = error as NSError
        
        guard nsError.domain == FirestoreErrorDomain else {
            return .unknown(error)
        }
        
        switch nsError.code {
        case FirestoreErrorCode.notFound.rawValue:
            return .documentNotFound
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .permissionDenied
        case FirestoreErrorCode.unavailable.rawValue:
            return .network
            
        default:
            return .unknown(error)
        }
    }
}
