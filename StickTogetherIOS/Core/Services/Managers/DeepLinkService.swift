//
//  DeepLink.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/11/2025.
//


import SwiftUI

enum DeepLink {
    case habit(habitId: String)
}

@MainActor
class DeepLinkService: ObservableObject {
    @Published var pendingHabitId: String? = nil
    @Published var authenticated: Bool = false
    
    func handle(url: URL) {
        guard url.scheme == "sticktogether",
              url.host == "habit",
              let habitId = url.pathComponents.dropFirst().first else {
            print("Invalid deep link: \(url)")
            return
        }
        
        self.pendingHabitId = habitId
    }
}
