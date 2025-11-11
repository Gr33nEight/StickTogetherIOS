//
//  CreateHabitViewAddToCalendar.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 11/11/2025.
//

import SwiftUI

extension CreateHabitView {
    var addToCalendarView: some View {
        VStack {
            Toggle("Add to calendar", isOn: $addToCalendar)
                .tint(Color.custom.primary)
                .padding(5)
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
            .onChange(of: alone) { oldValue, newValue in
                if newValue {
                    self.buddy = nil
                }
            }
    }
}
