//
//  MarkHabitAsCompleted.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/02/2026.
//

import Foundation

protocol MarkHabitAsCompletedUseCase {
    func execute(for id: String, on date: Date, forUser uid: String) async throws
}

final class MarkHabitAsCompletedUseCaseImpl: MarkHabitAsCompletedUseCase {
    private let repository: HabitRepository
    
    init(repository: HabitRepository) {
        self.repository = repository
    }
    
    func execute(for id: String, on date: Date, forUser uid: String) async throws {
        try await repository.updateData(with: id, updates: .completionState(date: date, userId: uid))
    }
}
