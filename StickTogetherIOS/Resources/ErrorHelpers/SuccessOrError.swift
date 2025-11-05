//
//  SuccessOrError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/11/2025.
//
import SwiftUI

enum SuccessOrError {
    case success
    case error(String)
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}
