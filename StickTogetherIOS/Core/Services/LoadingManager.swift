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

    func start() {
        counter += 1
        update()
    }
    
    func stop() {
        counter = max(0, counter - 1)
        update()
    }

    private func update() {
        isLoading = counter > 0
    }

    @discardableResult
    func run<T>(_ operation: @escaping @Sendable () async throws -> T) async rethrows -> T {
        start()
        defer { stop() }
        return try await operation()
    }
}
