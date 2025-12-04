//
//  HomeViewContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    var filteredHabits: [Habit] {
        visible.filter { habit in
            return habit.type == pickedHabitType
        }
    }
    
    func iAmOwner(_ ownerId: String) -> Bool {
        profileVM.safeUser.safeID == ownerId
    }
    
    func buddy(_ habit: Habit) -> User? {
        guard let buddyId = habit.buddyId else { return nil }
        
        return friendsVM.friends.first(where: {
            if let id = $0.id {
                return iAmOwner(habit.ownerId) ? id == buddyId : id == habit.ownerId
            }else{
                return false
            }
        })
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            picker
            ScrollView(showsIndicators: false) {
                if filteredHabits.isEmpty {
                    Spacer()
                    VStack {
                        Text("There are no \(pickedHabitType.text.lowercased()) habits scheduled for this day")
                            .foregroundStyle(Color.custom.lightGrey)
                            .font(.mySubtitle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        NavigationLink(destination: {
                            CreateHabitView() { habit in
                                Task { await habitVM.createHabit(habit) }
                            }.environmentObject(friendsVM)
                        }, label: {
                            HStack {
                                Image(systemName: "plus")
                                    .frame(height: 24)
                                Text("Add new")
                                    .font(.customAppFont(size: 15, weight: .semibold))
                            }
                        })
                        .foregroundStyle(Color.custom.tertiary)
                    }.padding(.top, UIScreen.main.bounds.height/5.5)
                    Spacer()
                } else {
                    ForEach(filteredHabits) { habit in
                        
                        NavigationLink {
                            HabitView(habitVM: habitVM, habit: habit, selectedDate: selectedDate, friends: friendsVM.friends)
                        } label: {
                            HabitCell(habit: habit, updateCompletion: {
                                Task { await habitVM.markHabitAsCompleted(habit, date: selectedDate) }
                            }, selectedDate: selectedDate, buddy: buddy(habit))
                        }
                    }
                }
            }.padding([.horizontal, .top], 20)
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
            }
            
            
        }.padding(.bottom, 100)
    }
    
    var picker: some View {
        HStack(spacing: 0) {
            ForEach(HabitType.allCases, id: \.self) { type in
                Button {
                    pickedHabitType = type
                } label: {
                    ZStack {
                        if pickedHabitType == type {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.custom.primary)
                                .matchedGeometryEffect(id: "habitsList-bg", in: habitTypeAnimation)
                        }
                        Text(type.text)
                            .font(.customAppFont(size: 13, weight: .bold))
                            .foregroundColor(pickedHabitType == type ? Color.custom.text : Color(.systemGray))
                            .frame(width: (UIScreen.main.bounds.size.width-60)/3, height: 40)
                    }
                }
            }
        }.animation(.bouncy, value: pickedHabitType)
            .frame(height: 30)
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
