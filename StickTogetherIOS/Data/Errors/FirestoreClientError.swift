//
//  FirestoreClientError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/05/2026.
//

import SwiftUI

enum FirestoreClientError: Error {
    case documentNotFound
    case decodingFailed
    case permissionDenied
    case network
    case unknown(Error)
}
