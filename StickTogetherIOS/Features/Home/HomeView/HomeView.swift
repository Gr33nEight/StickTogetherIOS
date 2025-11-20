//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

struct HomeView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @Environment(\.confirm) var confirm
    
    @State var selectedDate: Date = Date()
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()
    @State var pickedHabitType: HabitType = .coop
    
    @State var isEmojiPickerPresented = false
    @State var selectedEmoji: Emoji? = nil
    
    @Namespace var dayAnimation
    @Namespace var habitTypeAnimation

    let currentUser: User

    var visible: [Habit] {
        habitVM.habits.filter { $0.isScheduled(on: selectedDate) }
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
        .emojiPicker(isPresented: $isEmojiPickerPresented, selectedEmoji: $selectedEmoji)
    }
}
