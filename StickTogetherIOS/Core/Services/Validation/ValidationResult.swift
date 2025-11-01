//
//  ValidationResult.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//


import Foundation

enum ValidationResult {
    case success
    case failure(String)
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var message: String? {
        if case .failure(let m) = self { return m }
        return nil
    }
}

protocol AuthValidator {
    func validateName(_ name: String) -> ValidationResult
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateRePassword(_ password: String, _ rePassword: String) -> ValidationResult
    
    // helpers for flows
    func validateSignIn(email: String, password: String) -> [ValidationResult]
    func validateSignUp(name: String, email: String, password: String, rePassword: String) -> [ValidationResult]
}