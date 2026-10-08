//
//  LoadingManager.swift
//  StickTogetherIOS
//

import SwiftUI

/// App-wide loading state backed by independently balanced operation tokens.
@MainActor
final class LoadingManager: ObservableObject {
    static let shared = LoadingManager()

    @Published private(set) var isLoading = false

    private var activeOperations = Set<UUID>()
    private var hideTask: Task<Void, Never>?
    private var shownAt: Date?

    let minimumVisibleDuration: TimeInterval = 0.35
    private let hideDelay: TimeInterval = 0.08

    private init() {}

    /// Begins a loading operation. The returned token can be finished only once.
    @discardableResult
    func begin() -> UUID {
        hideTask?.cancel()
        hideTask = nil

        let token = UUID()
        activeOperations.insert(token)

        if activeOperations.count == 1 {
            shownAt = Date()
            withAnimation(.easeInOut(duration: 0.12)) {
                isLoading = true
            }
        }

        return token
    }

    /// Finishes the matching operation. Repeated or stale finishes are harmless.
    func finish(_ token: UUID) {
        guard activeOperations.remove(token) != nil,
              activeOperations.isEmpty else { return }

        let elapsed = Date().timeIntervalSince(shownAt ?? Date())
        let delay = max(hideDelay, minimumVisibleDuration - elapsed)

        hideTask?.cancel()
        hideTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(delay))
            } catch {
                return
            }

            guard let self, self.activeOperations.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.12)) {
                self.isLoading = false
            }
            self.shownAt = nil
            self.hideTask = nil
        }
    }

    @discardableResult
    func run<T>(_ operation: @MainActor () async throws -> T) async rethrows -> T {
        let token = begin()
        defer { finish(token) }
        return try await operation()
    }
}
