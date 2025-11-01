//
//  DefaultAuthValidator.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//


import Foundation

struct DefaultAuthValidator: AuthValidator {
    private let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    
    func validateName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .failure("Display name is required.") : .success
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure("Email is required.") }
        return (trimmed.range(of: emailRegex, options: .regularExpression) != nil)
            ? .success
            : .failure("Enter a valid email address.")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let pw = password
        guard !pw.isEmpty else { return .failure("Password is required.") }
        if pw.count < 8 { return .failure("Password must be at least 8 characters.") }
        if pw.range(of: "[A-Z]", options: .regularExpression) == nil {
            return .failure("Password must contain at least one uppercase letter.")
        }
        if pw.range(of: "[a-z]", options: .regularExpression) == nil {
            return .failure("Password must contain at least one lowercase letter.")
        }
        if pw.range(of: "\\d", options: .regularExpression) == nil {
            return .failure("Password must contain at least one digit.")
        }
        return .success
    }
    
    func validateRePassword(_ password: String, _ rePassword: String) -> ValidationResult {
        guard !rePassword.isEmpty else { return .failure("Please repeat the password.") }
        return (password == rePassword) ? .success : .failure("Passwords do not match.")
    }
    
    func validateSignIn(email: String, password: String) -> [ValidationResult] {
        return [validateEmail(email), (password.isEmpty ? .failure("Password is required.") : .success)]
    }
    
    func validateSignUp(name: String, email: String, password: String, rePassword: String) -> [ValidationResult] {
        return [ validateName(name),
                 validateEmail(email),
                 validatePassword(password),
                 validateRePassword(password, rePassword)
        ]
    }
}