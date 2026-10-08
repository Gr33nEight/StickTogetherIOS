//
//  FirestoreEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//


protocol FirestoreEndpoint: Sendable {
    associatedtype DTO: Codable
    static var path: String { get }
}
