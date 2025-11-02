//
//  AuthError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum AuthError: Error, LocalizedError {
    case invalidCredentials, missingUserId
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .missingUserId:
            return "Missing user id."
        }
    }
}
