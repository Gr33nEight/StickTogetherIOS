//
//  HabitEndpoint.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//


enum HabitEndpoint: FirestoreEndpoint {
    typealias DTO = HabitDTO
    static var path = "habits"
}