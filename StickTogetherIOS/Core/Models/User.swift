//
//  User.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct User: Identifiable {
    let id: UUID = UUID()
    let name: String
    let email: String
}
