//
//  ValueOrError.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/11/2025.
//
import SwiftUI

enum ValueOrError<T> {
    case value(T)
    case error(String)

    var value: T? {
        if case .value(let v) = self { return v }
        return nil
    }

    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }

    var isSuccess: Bool {
        if case .value = self { return true }
        return false
    }
}
