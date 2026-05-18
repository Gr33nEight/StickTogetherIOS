//
//  ListenToHabitUseCase.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 02/04/2026.
//

import Foundation

protocol ListenToHabitUseCase {
    func stream(for habitId: String) async throws -> AsyncThrowingStream<Habit, any Error>
}

final class ListenToHabitUseCaseImpl: ListenToHabitUseCase {
    private let habitRepository: HabitRepository

    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    func stream(
        for habitId: String
    ) -> AsyncThrowingStream<Habit, Error> {

        let repositoryStream =
            habitRepository.listenToHabit(with: habitId)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await habit in repositoryStream {
                        continuation.yield(habit)
                    }

                    continuation.finish()

                } catch {
                    continuation.finish(
                        throwing: mapError(error)
                    )
                }
            }
        }
    }

    private func mapError(_ error: Error)
    -> ListenToHabitError {

        switch error {

        case FirestoreClientError.documentNotFound:
            return .habitNotFound

        case FirestoreClientError.permissionDenied:
            return .permissionDenied

        default:
            return .failedToListen
        }
    }
}
