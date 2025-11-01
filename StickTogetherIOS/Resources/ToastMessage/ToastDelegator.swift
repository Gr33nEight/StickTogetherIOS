//
//  ToastDelegator.swift
//  PanstwaMiasta
//
//  Created by Natanael Jop on 01/11/2023.
//

import SwiftUI

@Observable class ToastDelegator {
    var show = false
    var timer: ToastMessageTimerModel
    var currentType: ToastMessage = .none
    
    init(show: Bool = false, currentType: ToastMessage = .none) {
        self.show = show
        self.timer = ToastMessageTimerModel()
        self.currentType = currentType
    }

    @MainActor
    public func present(_ type: ToastMessage, duration: Double = 3.0) {
        if timer.timeLeft <= 0 {
            show(type, duration)
        } else {
            hide()
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                self.show(type, duration)
            }
        }
    }

    @MainActor
    public func hide() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            self.show = false
        }
        self.timer.cancelTimer()
        self.currentType = .none
    }
    
    @MainActor
    private func show(_ type: ToastMessage, _ duration: Double) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.timer = ToastMessageTimerModel(timeLeft: duration)
        self.timer.restartTimer()
        self.currentType = type
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            self.show = true
        }
    }
}
