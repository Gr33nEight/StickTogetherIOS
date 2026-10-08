//
//  AuthSession.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

struct AuthSession {
    let uid: String
    let name: String?
    let email: String?

    init(uid: String, name: String? = nil, email: String? = nil) {
        self.uid = uid
        self.name = name
        self.email = email
    }
}
