//
//  CreateHabitViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import Foundation
import ElegantEmojiPicker

@MainActor
final class CreateHabitViewModel: ObservableObject {
    @Published var title = ""
    @Published var pickedFrequency: FrequencyType = .daily
    @Published var pickedDays = [Weekday]()
    @Published var interval = 1
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @Published var type: HabitType = .coop
    @Published var reminderTime = Date()
    @Published var buddy: User? = nil
    @Published var setReminder = false
    @Published var selectedEmoji: Emoji? = nil
    @Published var autoEmoji: String? = nil
    @Published var event: CreateHabitEvent?
    
    @Published private(set) var error: String?
    @Published private(set) var isLoading: Bool = false
    
    private let currentUserId: String
    private let createHabit: CreateHabitUseCase
    
    init(
        currentUserId: String,
        createHabit: CreateHabitUseCase
    ) {
        self.currentUserId = currentUserId
        self.createHabit = createHabit
    }
    
    func createHabit() async {
        do {
            let input = CreateHabitInput(
                title: title,
                icon: mapIcon(),
                frequency: mapFrequency(),
                startDate: startDate,
                endDate: endDate,
                reminderTime: reminderTime,
                type: type,
                buddyId: buddy?.id)
            
            try await createHabit.execute(input, for: currentUserId)
            event = .success
        } catch {
            event = .error(error.localizedDescription)
        }
    }
    
    private func mapFrequency() -> Frequency {
        switch pickedFrequency {
        case .daily:
            return .daily(everyDays: interval)
        case .weekly:
            return .weekly(everyWeeks: interval, daysOfWeek: pickedDays)
        case .monthly:
            return .monthly(everyMonths: interval)
        }
    }
    
    private func mapIcon() -> String {
        if let emoji = selectedEmoji?.emoji {
            return emoji
        } else if let autoEmoji {
            return autoEmoji
        } else {
            return ""
        }
    }
}
