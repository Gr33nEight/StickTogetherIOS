//
//  HomeViewTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import SwiftUI

struct HomeViewTemp: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var notificationsVM: NotificationsViewModel
    @Environment(\.navigate) var navigate
    
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()
    
    @Namespace var dayAnimation
    @Namespace var habitTypeAnimation
    
    var body: some View {
        VStack(spacing: 15) {
            header
            calendar
            content
        }
        .background(Color.custom.background)
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
        .task {
            await viewModel.onAppear()
        }
    }
}

extension HomeViewTemp {
    var header: some View {
        HStack {
            Text("\(Date().timeOfDayGreeting),\n\(viewModel.currentUserName.capitalized) 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            Button {
                navigate(.push(.notifications))
            } label: {
                Image(.bell)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }.customBadge(number: notificationsVM.numberOfUserNotReadNotifications)

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
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error)
            } else {
                VStack(spacing: 0) {
                    picker.padding(.bottom).padding([.top, .horizontal], 5)
                    if !viewModel.visibleHabits.isEmpty {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(viewModel.habitItems) { item in
                                    Button {
                                        let container = HabitViewContainer(habit: item.habit, selectedDate: viewModel.selectedDate)
                                        navigate(.push(.habit(container)))
                                    } label: {
                                        HabitCell(
                                            habitItem: item,
                                            selectedDate: viewModel.selectedDate,
                                        ) {
                                            guard let habitId = item.habit.id else { return }
                                                Task {
                                                    await viewModel.toggleHabitCompletion(of: habitId)
                                                }
                                            }
                                    }
                                }
                            }.padding(.bottom, Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: Date()) ? 130 : 0)
                        }
                    } else {
                        emptyView
                    }
                    if !Calendar.current.isDate(viewModel.selectedDate, inSameDayAs: Date()) {
                        Button {
                            viewModel.selectedDate = Date()
                            pageIndex = centerPage
                            baseWeekAnchor = viewModel.selectedDate
                        } label: {
                            Text("Return to today")
                        }.customButtonStyle(.primary)
                            .padding(.vertical, 15)
                            .padding(.bottom, 110)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            VStack {
                Text(viewModel.pickedHabitListType.noHabitsText)
                    .foregroundStyle(Color.custom.lightGrey)
                    .font(.mySubtitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                if viewModel.pickedHabitListType == .myHabits {
                    Button(action: {
                        navigate(.push(.createHabit))
                    }, label: {
                        HStack {
                            Image(systemName: "plus")
                                .frame(height: 24)
                            Text("Add new")
                                .font(.customAppFont(size: 15, weight: .semibold))
                        }
                    })
                    .foregroundStyle(Color.custom.tertiary)
                }
            }.padding(.bottom, 100)
            Spacer()
        }
    }
    
    var picker: some View {
        HStack(spacing: 0) {
            ForEach(HabitListType.allCases, id: \.self) { type in
                Button {
                    viewModel.pickedHabitListType = type
                } label: {
                    ZStack {
                        if viewModel.pickedHabitListType == type {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.custom.primary)
                                .matchedGeometryEffect(id: "habitsList-bg", in: habitTypeAnimation)
                        }
                        Text(type.text)
                            .font(.customAppFont(size: 13, weight: .bold))
                            .foregroundColor(viewModel.pickedHabitListType == type ? Color.custom.text : Color(.systemGray))
                            .frame(width: (UIScreen.main.bounds.size.width-80)/2, height: 40)
                    }
                }
            }
        }
            .frame(height: 40)
            .padding(.horizontal)
    }
}
