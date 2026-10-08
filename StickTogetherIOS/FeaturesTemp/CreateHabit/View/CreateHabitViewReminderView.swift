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
            Toggle("Set reminder", isOn: $viewModel.setReminder)
                .tint(Color.custom.primary)
                .padding(5)
            if viewModel.setReminder {
                DatePicker("Reminder time: ", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    .padding(.top, 10)
                    .padding(.horizontal, 5)
                    .datePickerStyle(.compact)
            }
        }.customCellViewModifier()
            .animation(.default, value: viewModel.setReminder)
    }
}
