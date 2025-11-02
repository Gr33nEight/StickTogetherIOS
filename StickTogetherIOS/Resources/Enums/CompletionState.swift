//
//  CompletionState.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum CompletionState: Int, Codable {
    case both, me, buddy, neither
    
    var text: String {
        switch self {
        case .both:
            "Both completed today"
        case .me:
            "You did it, buddy not yet"
        case .buddy:
            "Buddy did it and wait for you"
        case .neither:
            "Neither of you checked in yet"
        }
    }
}
