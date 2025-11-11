//
//  CreateHabitViewReminderView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateHabitView {
    var reminder: some View {
        VStack {
            Toggle("Set reminder", isOn: $setReminder)
                .tint(Color.custom.primary)
                .padding(5)
            if setReminder {
                DatePicker("Reminder time: ", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .padding(.top, 10)
                    .padding(.horizontal, 5)
                    .datePickerStyle(.compact)
            }
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
    }
}
