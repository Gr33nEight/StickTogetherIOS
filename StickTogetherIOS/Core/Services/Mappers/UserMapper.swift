//
//  UserMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

enum UserMapper {
    static func fromFirebaseUser(_ fu: FirebaseAuth.User) -> User {
        User(
            id: fu.uid,
            name: fu.displayName ?? fu.email?.components(separatedBy: "@").first ?? "User",
            email: fu.email ?? ""
        )
    }
}
