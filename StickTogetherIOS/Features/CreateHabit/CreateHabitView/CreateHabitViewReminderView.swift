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
                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .padding(10)
                    .padding(.horizontal, 5)
                    .frame(width: 1)
                    .datePickerStyle(.wheel)
            }
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
    }
}
