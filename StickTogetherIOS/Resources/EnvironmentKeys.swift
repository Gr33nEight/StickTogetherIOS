//
//  EnvironmentKeys.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//

import SwiftUI

struct ToastMessageEnvironmentKey: EnvironmentKey {
    static var defaultValue: ToastMessageService = ToastMessageService { _ in }
}

extension EnvironmentValues {
    var showToastMessage: ToastMessageService {
        get { self[ToastMessageEnvironmentKey.self] }
        set { self[ToastMessageEnvironmentKey.self] = newValue }
    }
}

struct ConfirmatiomEnvironmentKey: EnvironmentKey {
    static var defaultValue: ConfirmationService = ConfirmationService { _ in}
}

extension EnvironmentValues {
    var confirm: (ConfirmationService) {
        get { self[ConfirmatiomEnvironmentKey.self] }
        set { self[ConfirmatiomEnvironmentKey.self] = newValue }
    }
}
