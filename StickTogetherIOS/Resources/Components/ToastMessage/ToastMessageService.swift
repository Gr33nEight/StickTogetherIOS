//
//  ToastMessageService.swift
//  QueensGame
//
//  Created by Natanael Jop on 16/07/2025.
//
import SwiftUI

struct ToastMessageService {
    typealias Action = (ToastMessage) -> Void
    let action: Action
    
    func callAsFunction(_ toastMessage: ToastMessage) {
        action(toastMessage)
    }
}

