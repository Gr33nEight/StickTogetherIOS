//
//  FirestoreQuery.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//


struct FirestoreQuery {
    var filters: [FirestoreFilter] = []
    var limit: Int?
    var order: (field: String, descending: Bool)?
}

extension FirestoreQuery {
    /// Stable representation used to distinguish cached query results.
    var cacheKey: String {
        let filterKeys = filters.map { filter -> String in
            switch filter {
            case .isEqual(let field, let value): return "eq:\(field.cacheKey):\(value.cacheKey)"
            case .arrayContains(let field, let value): return "contains:\(field.cacheKey):\(value.cacheKey)"
            case .greaterThan(let field, let value): return "gt:\(field.cacheKey):\(value.cacheKey)"
            case .greaterThanOrEqualTo(let field, let value): return "gte:\(field.cacheKey):\(value.cacheKey)"
            case .lessThan(let field, let value): return "lt:\(field.cacheKey):\(value.cacheKey)"
            case .lessThanOrEqualTo(let field, let value): return "lte:\(field.cacheKey):\(value.cacheKey)"
            case .isIn(let field, let values): return "in:\(field.cacheKey):[\(values.map(\.cacheKey).joined(separator: ","))]"
            }
        }
        let ordering = order.map { "\($0.field):\($0.descending)" } ?? "none"
        return "\(filterKeys.joined(separator: "&"))|limit:\(limit.map(String.init) ?? "none")|order:\(ordering)"
    }
}

private extension FirestoreField {
    var cacheKey: String {
        switch self {
        case .field(let name): return "field:\(name)"
        case .documentId: return "documentId"
        }
    }
}

private extension FirestoreValue {
    var cacheKey: String {
        switch self {
        case .string(let value): return "s:\(value)"
        case .int(let value): return "i:\(value)"
        case .bool(let value): return "b:\(value)"
        case .date(let value): return "d:\(value.timeIntervalSince1970)"
        }
    }
}

extension FirestoreQuery {

    func isEqual(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.isEqual(field: field, value: value))
        return copy
    }

    func arrayContains(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.arrayContains(field: field, value: value))
        return copy
    }

    func greaterThan(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.greaterThan(field: field, value: value))
        return copy
    }

    func greaterThanOrEqualTo(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.greaterThanOrEqualTo(field: field, value: value))
        return copy
    }

    func lessThan(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.lessThan(field: field, value: value))
        return copy
    }
    
    func lessThanOrEqualTo(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.lessThanOrEqualTo(field: field, value: value))
        return copy
    }

    func isIn(
        _ field: FirestoreField,
        _ values: [FirestoreValue]
    ) -> Self {
        var copy = self
        copy.filters.append(.isIn(field: field, values: values))
        return copy
    }

    func limit(_ value: Int) -> Self {
        var copy = self
        copy.limit = value
        return copy
    }

    func order(by field: String, descending: Bool = false) -> Self {
        var copy = self
        copy.order = (field, descending)
        return copy
    }
}
