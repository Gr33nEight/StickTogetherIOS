//
//  CompletionState.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum CompletionState: Int, Codable, CaseIterable {
    case both, me, buddy, neither
    
    var text: String {
        switch self {
        case .both:
            "Both completed today"
        case .me:
            "You did it, buddy not yet"
        case .buddy:
            "Buddy did it and waits for you"
        case .neither:
            "Neither of you checked in yet"
        }
    }
}
