//
//  CalendarView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CalendarView: View {
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
                            Circle()
                                .foregroundStyle(.clear)
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
        let isDifferentMonth = day.monthInt != currentMonth.monthInt
        let isPastDate = day < Date.now.startOfDay
        
        if isDifferentMonth {
            return Color(.systemGray)
        } else if isPastDate {
            return Color.custom.text
        } else {
            return Color(.systemGray)
        }
    }
}
