//
//  HabitEntryRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation

protocol HabitEntryRepository {
    func saveEntry(_ entry: HabitEntry) async throws
}
