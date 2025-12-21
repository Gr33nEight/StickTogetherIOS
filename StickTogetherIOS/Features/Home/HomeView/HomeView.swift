//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

enum HabitListType: CaseIterable {
    case myHabits
    case friendsHabits
    
    var text: String {
        switch self {
        case .myHabits:
            return "My Habits"
        case .friendsHabits:
            return "Friends' Habits"
        }
    }
    
    var noHabitsText: String {
        switch self {
        case .myHabits:
            return "You don’t have any habits yet."
        case .friendsHabits:
            return "Your friends haven’t shared any preview habits yet."
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var appNotificationsVM: AppNotificationsViewModel
    
    @Environment(\.confirm) var confirm
    @Environment(\.navigate) var navigate
    
    @State var selectedDate: Date = Date()
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()
    @State var pickedHabitListType: HabitListType = .myHabits
    
    @Namespace var dayAnimation
    @Namespace var habitTypeAnimation
    
    var myHabitsOnDate: [Habit] {
        habitVM.habits.filter { $0.isScheduled(on: selectedDate) }
    }
    
    var buddiesHabitsOnDate: [Habit] {
        habitVM.friendsHabits.filter { $0.isScheduled(on: selectedDate) }
    }

    var body: some View {
        VStack(spacing: 15) {
            header
            calendar
            content
        }
        .background(Color.custom.background)
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
    }
}
