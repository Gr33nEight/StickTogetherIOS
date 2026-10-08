import Foundation

/// Short-lived decoded-response cache layered above Firestore's persistent offline cache.
/// Firestore remains the source of truth; writes and live snapshots invalidate affected data.
final class FirestoreResponseCache {
    static let shared = FirestoreResponseCache()

    private struct Entry {
        let data: Data
        let expiresAt: Date
    }

    private let lock = NSLock()
    private var entries: [String: Entry] = [:]
    private let lifetime: TimeInterval = 20
    private let maximumEntries = 256

    private init() {}

    func value<T: Decodable>(for key: String, as type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }

        guard let entry = entries[key] else { return nil }
        guard entry.expiresAt > Date() else {
            entries.removeValue(forKey: key)
            return nil
        }
        return try? JSONDecoder().decode(type, from: entry.data)
    }

    func store<T: Encodable>(_ value: T, for key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        lock.lock()
        defer { lock.unlock() }

        if entries.count >= maximumEntries, entries[key] == nil,
           let oldestKey = entries.min(by: { $0.value.expiresAt < $1.value.expiresAt })?.key {
            entries.removeValue(forKey: oldestKey)
        }
        entries[key] = Entry(data: data, expiresAt: Date().addingTimeInterval(lifetime))
    }

    func invalidate(endpoint: String) {
        lock.lock()
        defer { lock.unlock() }
        entries = entries.filter { !$0.key.hasPrefix("\(endpoint)|") }
    }
}
