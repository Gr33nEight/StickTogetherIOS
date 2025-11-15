//
//  CalendarView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CalendarView: View {
    let completion: (Date) -> BaseCompletionState
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
                                        .fill(Color.custom.primary)
                                }else{
                                    Circle()
                                        .fill(completion(day).color)
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
        let isToday = Calendar.current.isDateInToday(day)
        let isDifferentMonth = day.monthInt != currentMonth.monthInt
        let isPast = day < Date.now.startOfDay
        let isOlderThanHabit = day < startDate

        if isToday || completion(day) == .skipped {
            return Color.custom.text
        }

        if completion(day) == .done {
            return Color.custom.grey
        }

        if isDifferentMonth || isOlderThanHabit {
            return Color(.systemGray)
        }

        if isPast {
            return Color.custom.text
        }

        return Color(.systemGray)
    }
}
