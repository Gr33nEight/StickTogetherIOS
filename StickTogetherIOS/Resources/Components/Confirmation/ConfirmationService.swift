//
//  ConfirmationService.swift
//  QueensGame
//
//  Created by Natanael Jop on 17/07/2025.
//

import SwiftUI

struct Confirmation: Identifiable {
    var id = UUID()
    var question: String
    var yesAction: () -> Void
    var noAction: () -> Void
}

struct ConfirmationService {
    typealias Action = (Confirmation) -> Void
    let action: Action
    
    func callAsFunction(question: String = "Are you sure?", yesAction: @escaping () -> Void, noAction: @escaping () -> Void = {}) {
        let confirmation = Confirmation(question: question, yesAction: yesAction, noAction: noAction)
        action(confirmation)
    }
}
