import SwiftUI

@MainActor
final class LoadingManager: ObservableObject {
    /// A reference count of active operations. >0 => show loader.
    @Published private(set) var isLoading: Bool = false
    private var counter: Int = 0

    /// Call when starting an async operation
    func start() {
        counter += 1
        update()
    }

    /// Call when finishing an async operation
    func stop() {
        counter = max(0, counter - 1)
        update()
    }

    private func update() {
        // simple hysteresis could be added here
        isLoading = counter > 0
    }

    /// Utility: run an async closure while showing loader, automatically stopping on return or error.
    @discardableResult
    func run<T>(_ operation: @escaping @Sendable () async throws -> T) async rethrows -> T {
        start()
        defer { stop() }
        return try await operation()
    }
}