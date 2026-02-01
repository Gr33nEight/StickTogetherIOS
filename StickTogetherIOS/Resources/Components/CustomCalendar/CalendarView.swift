//
//  CalendarView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CalendarView: View {
    let habit: Habit
    let state: (Date) -> HabitState
    let startDate: Date
    
    @State private var currentMonth = Date.now
    @State private var days: [Date] = []
    
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(currentMonth.formatted(.dateTime.year().month()))
                Spacer()
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.custom.primary)
                }
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.custom.primary)
                    
                }
            }.font(.myHeadline)
            
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .font(.myBody)
                        .foregroundStyle(Color.custom.text)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid of days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Text(day.formatted(.dateTime.day()))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(foregroundStyle(for: day))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            ZStack {
                                if Calendar.current.startOfDay(for: Date()) == day {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .fill(state(day).color)
                                }else{
                                    Circle()
                                        .fill(state(day).color)
                                }
                            }
                        )
                        .disabled(day < Date.now.startOfDay || day.monthInt != currentMonth.monthInt)
                }
            }
        }
        .customCellViewModifier()
        .onAppear {
            updateDays()
        }
    }
    
    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }
 
    private func foregroundStyle(for day: Date) -> Color {
        let calendar = Calendar.current

        let todayStart = calendar.startOfDay(for: Date())
        let isInHabitRange =
            day >= calendar.startOfDay(for: startDate) &&
            day <= todayStart

        let isDifferentMonth = day.monthInt != currentMonth.monthInt

        if isInHabitRange {
            return Color.custom.text
        }

        if isDifferentMonth {
            return Color.custom.background
        }

        return Color(.systemGray)
    }
}
