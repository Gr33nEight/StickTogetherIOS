//
//  ListenToEntriesError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/05/2026.
//

import Foundation

enum ListenToEntriesError: LocalizedError {
    case failedToListen
    
    var errorDescription: String? {
        switch self {
        case .failedToListen:
            return "Failed to sync habit entries"
        }
    }
}
