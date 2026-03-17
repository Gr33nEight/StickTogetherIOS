//
//  ListenToHabitsUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

protocol ListenToHabitsUseCase {
    func stream(for id: String) async throws -> AsyncThrowingStream<[Habit], any Error>
}
