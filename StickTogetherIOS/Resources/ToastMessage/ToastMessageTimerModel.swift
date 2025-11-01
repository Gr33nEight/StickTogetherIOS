//
//  TimerModel.swift
//  PanstwaMiasta
//
//  Created by Natanael Jop on 01/11/2023.
//

import SwiftUI
import Combine

import SwiftUI
import Combine

final class ToastMessageTimerModel: ObservableObject {
    @Published var timeLeft: Double
    @Published var timerOn: Bool = false

    private(set) var countdownFrom: Double = 0
    var timer = Timer.publish(every: 1, on: .main, in: .common)
    private var connectedTimer: Cancellable?

    init(timeLeft: Double = 10) {
        self.timeLeft = timeLeft
        self.countdownFrom = timeLeft
    }

    func instantiateTimer() {
        self.timerOn = true
        self.timeLeft = countdownFrom
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
        self.connectedTimer = timer.connect()
    }

    func cancelTimer() {
        self.timerOn = false
        self.connectedTimer?.cancel()
        self.connectedTimer = nil
    }

    func restartTimer() {
        cancelTimer()
        instantiateTimer()
    }

    func decrementTime() {
        guard timerOn else { return }
        timeLeft -= 1
    }
}
