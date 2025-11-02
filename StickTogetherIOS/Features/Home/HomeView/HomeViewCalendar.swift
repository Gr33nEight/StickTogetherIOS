//
//  HomeViewCalendar.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    // adjust these constants if you want more/less history/future
    private var pagesRange: ClosedRange<Int> { 0...1000 }
    private var centerPage: Int { (pagesRange.lowerBound + pagesRange.upperBound) / 2 }

    var calendar: some View {
        VStack(spacing: 8) {
            TabView(selection: $pageIndex) {
                ForEach(pagesRange, id: \.self) { idx in
                    let weekOffset = idx - centerPage
                    // compute anchor date for this page (shift by weeks from the baseSelectedDate)
                    let anchor = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: baseWeekAnchor) ?? baseWeekAnchor
                    
                    HStack(spacing: 0) {
                        ForEach(weekDates(around: anchor), id: \.self) { date in
                            DayCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                                .onTapGesture {
                                    selectedDate = date
                                }
                        }
                    }
                    .padding()
                    .tag(idx)
                }.padding(.horizontal, 20)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 60)
            .onChange(of: pageIndex) { _, new in
                // when page changes, compute the week's dates (for the new page)
                let weekOffset = new - centerPage
                let anchor = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: baseWeekAnchor) ?? baseWeekAnchor
                let week = weekDates(around: anchor)
                
                // If this week contains today -> select today, otherwise select FIRST day of that week
                let today = Calendar.current.startOfDay(for: Date())
                if week.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    selectedDate = today
                } else if let first = week.first {
                    selectedDate = first
                }
            }
        }
        .onAppear {
            // start centered on current week
            pageIndex = centerPage
            baseWeekAnchor = selectedDate

            // Decide initial selection similarly: if current week contains today -> today, otherwise first day
            let week = weekDates(around: baseWeekAnchor)
            let today = Calendar.current.startOfDay(for: Date())
            if week.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                selectedDate = today
            } else if let first = week.first {
                selectedDate = first
            }
        }
    }
    
    private func weekDates(around anchor: Date) -> [Date] {
        let calendar = Calendar.current
        // Determine start of week according to calendar.firstWeekday (1 = Sunday, 2 = Monday)
        let anchorStart = calendar.startOfDay(for: anchor)
        let weekday = calendar.component(.weekday, from: anchorStart)
        // compute offset to firstWeekday
        let firstWeekday = calendar.firstWeekday // system locale dependent
        // distance from anchor weekday to firstWeekday in 0..6
        let offset = (7 + (weekday - firstWeekday)) % 7
        guard let weekStart = calendar.date(byAdding: .day, value: -offset, to: anchorStart) else {
            return [anchorStart]
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
}

// MARK: - Array safe index helper
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
