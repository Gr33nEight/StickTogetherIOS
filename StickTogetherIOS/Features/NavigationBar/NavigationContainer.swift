//
//  NavigationContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct NavigationContainer: View {
    @StateObject var habitVM: HabitViewModel
    @StateObject var friendsVM: FriendsViewModel
    
    @Binding var selected: NavigationDestinations
    let currentUser: User

    init(currentUser: User,
         selected: Binding<NavigationDestinations>,
         habitService: HabitServiceProtocol,
         friendsService: FriendsServiceProtocol,
         authService: AuthServiceProtocol,
         authVM: AuthViewModel,
         loading: LoadingManager? = nil) {

        let habitVM = HabitViewModel(service: habitService,
                                     loading: loading,
                                     currentUser: currentUser)
        _habitVM = StateObject(wrappedValue: habitVM)
        
        let friendsVM = FriendsViewModel(authService: authService, friendsService: friendsService,
                                         loading: loading, currentUser: currentUser)
        _friendsVM = StateObject(wrappedValue: friendsVM)
    
    
        self.currentUser = currentUser
        self._selected = selected
    }
    
    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                NavigationBarView(selected: $selected) {
                    CreateHabitView(friendsVM: friendsVM, currentUser: currentUser) { habit in
                        Task { await habitVM.createHabit(habit) }
                    }
                }
                .padding(.horizontal)
            }
        }.task {
            await habitVM.startListening()
            await friendsVM.startFriendsListener()
        }
        .environmentObject(habitVM)
        .environmentObject(friendsVM)
    }

    @ViewBuilder
    private var content: some View {
        switch selected {
        case .home:
            HomeView(currentUser: currentUser)
        case .stats:
            StatsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.custom.background)

        case .chats:
            ChatsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.custom.background)
        case .friends:
            FriendsListView(fullList: true, friendsVM: friendsVM, currentUser: currentUser)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.custom.background)

        case .settings:
            SettingsView(currentUser: currentUser)
        }
    }
}
