//
//  LoadingManager.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//

import SwiftUI

@MainActor
final class LoadingManager: ObservableObject {
    @Published private(set) var isLoading: Bool = false

    private var counter: Int = 0
    private var hideTask: Task<Void, Never>?
    private var shownAt: Date?

    /// Minimum time the loader should be visible (to avoid flicker)
    let minVisibleDuration: TimeInterval = 0.35
    /// Minimum delay before attempting to hide after counter drops to zero
    let hideDelay: TimeInterval = 0.08

    func start() {
        // cancel any scheduled hide
        hideTask?.cancel()
        hideTask = nil

        counter += 1

        // if this is the first start, show immediately
        if counter == 1 {
            shownAt = Date()
            withAnimation(.easeInOut(duration: 0.12)) {
                isLoading = true
            }
        }
    }

    func stop() {
        counter = max(0, counter - 1)

        // only schedule hiding when counter reaches zero
        if counter == 0 {
            scheduleHide()
        }
    }

    private func scheduleHide() {
        hideTask?.cancel()

        // compute how much longer we must keep the loader visible to satisfy minVisibleDuration
        let alreadyShown = -((shownAt ?? Date()).timeIntervalSinceNow) // time interval since shownAt
        let remainingForMinVisible = max(0, minVisibleDuration - alreadyShown)

        // choose delay: ensure we wait at least remainingForMinVisible, but at least hideDelay
        let delay = max(hideDelay, remainingForMinVisible)

        hideTask = Task.detached { [weak self] in
            // Sleep (can be cancelled)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            await MainActor.run {
                guard let self = self else { return }
                // only hide if still zero
                if self.counter == 0 {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        self.isLoading = false
                    }
                    self.shownAt = nil
                }
                self.hideTask = nil
            }
        }
    }

    @discardableResult
    func run<T>(_ operation: @escaping @MainActor @Sendable () async throws -> T) async rethrows -> T {
        start()
        defer { stop() }
        return try await operation()
    }
}
