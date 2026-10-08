//
//  UserEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

enum UserEndpoint: FirestoreEndpoint {
    typealias DTO = UserDTO
    static var path: String = "users"
}
