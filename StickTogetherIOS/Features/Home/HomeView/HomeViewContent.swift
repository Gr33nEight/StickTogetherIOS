//
//  HomeViewContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    var pickedListHabits: [Habit] {
        switch pickedHabitListType {
        case .myHabits: myHabitsOnDate
        case .friendsHabits: buddiesHabitsOnDate
        }
    }
    
    var sortedHabits: [Habit] {
        return pickedListHabits.sorted { a, b in
            let aPriority = a.sortPriority(date: selectedDate, currentUserId: profileVM.safeUser.safeID)
            let bPriority = b.sortPriority(date: selectedDate, currentUserId: profileVM.safeUser.safeID)
            
            if aPriority != bPriority {
                return aPriority > bPriority
            }
            
            let aDate = habitVM.lastInteraction[a.id ?? ""] ?? .distantPast
            let bDate = habitVM.lastInteraction[b.id ?? ""] ?? .distantPast

            if aDate != bDate {
                return aDate < bDate
            }
            
            return a.title > b.title
        }
    }
    
    func iAmOwner(_ ownerId: String) -> Bool {
        profileVM.safeUser.safeID == ownerId
    }
    
    func buddy(_ habit: Habit) -> User? {
        guard !habit.buddyId.isEmpty else { return nil }
        
        return friendsVM.friends.first(where: {
            if let id = $0.id {
                return iAmOwner(habit.ownerId) ? id == habit.buddyId : id == habit.ownerId
            }else{
                return false
            }
        })
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            picker.padding(.bottom).padding([.top, .horizontal], 5)
            ScrollView(showsIndicators: false) {
                if sortedHabits.isEmpty {
                    Spacer()
                    VStack {
                        Text(pickedHabitListType.noHabitsText)
                            .foregroundStyle(Color.custom.lightGrey)
                            .font(.mySubtitle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        if pickedHabitListType == .myHabits {
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
                    }.padding(.top, UIScreen.main.bounds.height/5.5)
                    Spacer()
                } else {
                    VStack {
                        ForEach(sortedHabits) { habit in
                            Button {
                                let container = HabitViewContainer(habitId: habit.id, selectedDate: selectedDate, friends: friendsVM.friends)
                                navigate(.push(.habit(container)))
                            } label: {
                                HabitCell(habit: habit, selectedDate: selectedDate, buddy: buddy(habit)) {
                                    Task { await habitVM.markHabitAsCompleted(habit, date: selectedDate) }
                                }
                            }
                        }
                    }.padding(.bottom, Calendar.current.isDate(selectedDate, inSameDayAs: Date()) ? 130 : 0)
                }
            }.padding(.horizontal, 20)
            
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                Button {
                    selectedDate = Date()
                    pageIndex = centerPage
                    baseWeekAnchor = selectedDate
                } label: {
                    Text("Return to today")
                }.customButtonStyle(.primary)
                    .padding(.horizontal, 5)
                    .padding(15)
                    .padding(.bottom, 110)
            }
        }
    }
    
    var picker: some View {
        HStack(spacing: 0) {
            ForEach(HabitListType.allCases, id: \.self) { type in
                Button {
                    pickedHabitListType = type
                } label: {
                    ZStack {
                        if pickedHabitListType == type {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.custom.primary)
                                .matchedGeometryEffect(id: "habitsList-bg", in: habitTypeAnimation)
                        }
                        Text(type.text)
                            .font(.customAppFont(size: 13, weight: .bold))
                            .foregroundColor(pickedHabitListType == type ? Color.custom.text : Color(.systemGray))
                            .frame(width: (UIScreen.main.bounds.size.width-60)/2, height: 40)
                    }
                }
            }
        }
            .frame(height: 40)
            .padding(.horizontal)
    }
}

//#Preview {
//    let user = User(name: "Natanael", email: "")
//    HomeView(currentUser: user)
//        .environmentObject(AuthViewModel())
//        .environmentObject(HabitViewModel(service: MockHabitService(), currentUser: user))
//        .environmentObject(FriendsViewModel(authService: MockAuthService(), friendsService: MockFriendsService(), currentUser: user))
//        .preferredColorScheme(.dark)
//}


enum HabitType: Int, CaseIterable, Codable {
    case alone, coop, preview
    
    var text: String {
        switch self {
        case .alone:
            return "Alone"
        case .coop:
            return "Co-op"
        case .preview:
            return "Preview"
        }
    }
}
