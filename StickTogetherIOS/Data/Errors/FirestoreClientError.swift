//
//  FirestoreClientError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//

import SwiftUI

enum FirestoreClientError: LocalizedError {
    case documentNotFound
    case decodingFailed
    case permissionDenied
    case network
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"

        case .decodingFailed:
            return "Failed to decode document"

        case .permissionDenied:
            return "Permission denied"

        case .network:
            return "Network error"

        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
