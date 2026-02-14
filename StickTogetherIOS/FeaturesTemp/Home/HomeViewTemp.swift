//
//  HomeViewTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import SwiftUI

struct HomeViewTemp: View {
    @StateObject var viewModel: HomeViewModel
    @Environment(\.navigate) var navigate
    
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()
    
    var body: some View {
        VStack(spacing: 15) {
            header
            calendar
            content
        }.onAppear {
            viewModel.startListening()
        }
    }
}

extension HomeViewTemp {
//    var numberOfUnReadNotifications: Int {
//        appNotificationsVM.appNotifications.filter({!$0.isRead && $0.type == .friendMessage}).count
//    }
    var header: some View {
        HStack {
//            Text("\(Date().timeOfDayGreeting),\n\(profileVM.safeUser.name.capitalized) 👋")
            Text("\(Date().timeOfDayGreeting),\nNatanael Jop 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            Button {
                navigate(.push(.notifications))
            } label: {
                Image(.bell)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }//.customBadge(number: numberOfUnReadNotifications)

        }.foregroundStyle(Color.custom.text)
            .padding([.top, .horizontal], 20)
    }
}

extension HomeViewTemp {
    var pagesRange: ClosedRange<Int> { 0...1000 }
    var centerPage: Int { (pagesRange.lowerBound + pagesRange.upperBound) / 2 }

    var calendar: some View {
        VStack(spacing: 8) {
            TabView(selection: $pageIndex) {
                ForEach(pagesRange, id: \.self) { idx in
                    let weekOffset = idx - centerPage
                    
                    let anchor = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: baseWeekAnchor) ?? baseWeekAnchor
                    
                    HStack(spacing: 10) {
                        ForEach(weekDates(around: anchor), id: \.self) { date in
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                            
                            DayCell(date: date, isSelected: isSelected, done: /*habitVM.habitStats(on: date).done*/ 10, skipped: /*habitVM.habitStats(on: date).skipped*/ 5)
                                .onTapGesture {
                                    withAnimation(.bouncy) {
                                        viewModel.selectedDate = date
                                    }
                                }
                        }
                    }
                    .padding(.vertical)
                    .tag(idx)
                }.padding(.horizontal)
            }.frame(height: 64)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: pageIndex) { _, new in
                let weekOffset = new - centerPage
                let anchor = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: baseWeekAnchor) ?? baseWeekAnchor
                let week = weekDates(around: anchor)
                
                let today = Calendar.current.startOfDay(for: Date())
                if week.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    viewModel.selectedDate = today
                } else if let first = week.first {
                    viewModel.selectedDate = first
                }
            }
        }
        .onAppear {
            pageIndex = centerPage
            baseWeekAnchor = viewModel.selectedDate

            let week = weekDates(around: baseWeekAnchor)
            let today = Calendar.current.startOfDay(for: Date())
            if week.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                viewModel.selectedDate = today
            } else if let first = week.first {
                viewModel.selectedDate = first
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
        let week = weekDates(around: anchor)
        guard let first = week.first, let last = week.last else {
            return DateFormatter.localizedString(from: anchor, dateStyle: .medium, timeStyle: .none)
        }
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        return "\(df.string(from: first)) — \(df.string(from: last))"
    }
}


extension HomeViewTemp {
    private var content: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            }
            
            if !viewModel.isLoading && viewModel.visibleHabits.isEmpty {
                Text("Puste")
            }
            
            if let error = viewModel.error {
                Text(error)
            }
            
            ScrollView {
                VStack {
                    ForEach(viewModel.visibleHabits) { habit in
                        HabitCell(habit: habit, selectedDate: Date(), buddy: nil) {
                            //
                        }
                    }
                }
            }
        }
    }
}
