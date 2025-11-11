//
//  HomeViewCalendar.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    // adjust these constants if you want more/less history/future
    var pagesRange: ClosedRange<Int> { 0...1000 }
    var centerPage: Int { (pagesRange.lowerBound + pagesRange.upperBound) / 2 }

    var calendar: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    withAnimation { pageIndex = max(pagesRange.lowerBound, pageIndex - 1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }

                Spacer()

                Text(weekLabel(for: selectedDate))
                    .font(.customAppFont(size: 14, weight: .semibold))
                    .foregroundStyle(Color.custom.text)

                Spacer()

                Button {
                    withAnimation { pageIndex = min(pagesRange.upperBound, pageIndex + 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }
            }
            .padding(.horizontal, 15)
            TabView(selection: $pageIndex) {
                ForEach(pagesRange, id: \.self) { idx in
                    let weekOffset = idx - centerPage
                    
                    let anchor = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: baseWeekAnchor) ?? baseWeekAnchor
                    
                    HStack(spacing: 10) {
                        ForEach(weekDates(around: anchor), id: \.self) { date in
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            DayCell(date: date, isSelected: isSelected, wasDone: habitVM.wasDone(on: date))
                                .onTapGesture {
                                    selectedDate = date
                                }
                        }
                    }
                    .padding(.vertical)
                    .tag(idx)
                }.padding(.horizontal)
            }.frame(height: 68)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
    
    private func weekLabel(for anchor: Date) -> String {
        let calendar = Calendar.current
        let week = weekDates(around: anchor)
        guard let first = week.first, let last = week.last else {
            return DateFormatter.localizedString(from: anchor, dateStyle: .medium, timeStyle: .none)
        }
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        return "\(df.string(from: first)) — \(df.string(from: last))"
    }
}

// MARK: - Array safe index helper
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
