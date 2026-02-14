//
//  FirestoreQuery.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//


struct FirestoreQuery {
    var filters: [FirestoreFilter]
    var limit: Int?
    var order: (field: String, descending: Bool)?
    
    func whereField(field: String, op: FirestoreFilterOperator, value: FirestoreValue) -> Self {
        var copy = self
        copy.filters.append(FirestoreFilter(field: field, op: op, value: value))
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