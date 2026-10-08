//
//  CompletionState.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

enum CompletionState: Int, Codable, CaseIterable {
    case all, onlyMe, onlyOthers, meAndOthers, none
    
    var text: String {
        switch self {
        case .all:
            "You and your buddies completed today"
        case .onlyMe:
            "Only you did it"
        case .onlyOthers:
            "You didn't checked in yet"
        case .meAndOthers:
            "You and some other buddies checked in"
        case .none:
            "Noone checked in yet"
        }
    }
}
