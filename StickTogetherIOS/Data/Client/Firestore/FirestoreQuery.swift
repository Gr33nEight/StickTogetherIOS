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

    func lessThan(
        _ field: FirestoreField,
        _ value: FirestoreValue
    ) -> Self {
        var copy = self
        copy.filters.append(.lessThan(field: field, value: value))
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
