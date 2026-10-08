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
    
    private func habitValidation() -> Bool {
        guard !title.isEmpty else {
            event = .error("Please add a title")
            return false
        }
        
        guard startDate <= endDate else {
            event = .error("Start date must be before end date")
            return false
        }
        
        if pickedDays.isEmpty && pickedFrequency == .weekly {
            event = .error("Please select at least one day")
            return false
        }
        
        if type == .coop || type == .preview, buddy == nil {
            event = .error("Please select a buddy")
            return false
        }
        
        return true
    }
    
    func createHabit() async {
        guard habitValidation() else { return }
        
        do {
            let input = CreateHabitInput(
                title: title,
                icon: mapIcon(),
                frequency: mapFrequency(),
                startDate: startDate,
                endDate: endDate,
                reminderTime: reminderTime,
                type: type,
                buddyIds: buddy?.id.map { [$0] } ?? []
            )
            //TODO: Fix later
            
            try await createHabit.execute(input, for: currentUserId)
            event = .success
        } catch {
            event = .error(error.localizedDescription)
        }
    }
}
