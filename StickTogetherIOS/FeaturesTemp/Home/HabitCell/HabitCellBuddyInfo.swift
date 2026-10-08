//
//  HabitCellBuddyInfo.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/12/2025.
//

import SwiftUI

struct HabitCellBuddyInfo: Identifiable, Hashable {
    let id: String
    let buddyStatusColor: Color
    let buddyBadgeColor: Color
    let buddyName: String
    let showStatusBadge: StatusBadgeType?
}

enum StatusBadgeType: CaseIterable {
    case xmark, checkmark, invited
    
    var imageName: String {
        switch self {
        case .xmark:
            return "xmark"
        case .checkmark:
            return "checkmark"
        case .invited:
            return "envelope.fill"
        }
    }
}
