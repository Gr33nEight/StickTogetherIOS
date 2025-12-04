//
//  NavigationContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct NavigationContainer: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var loading: LoadingManager
    
    @Binding var selected: NavigationDestinations
    
    @StateObject private var habitVM: HabitViewModel
    @StateObject private var friendsVM: FriendsViewModel
    @StateObject private var appNotificationsVM: AppNotificationsViewModel
    
    init(selected: Binding<NavigationDestinations>,
         habitService: HabitServiceProtocol,
         friendsService: FriendsServiceProtocol,
         profileService: ProfileServiceProtocol,
         appNotificationsService: AppNotificationsServiceProtocol,
         currentUser: User,
         loading: LoadingManager? = nil) {
        
        let habitVM = HabitViewModel.configured(service: habitService,
                                                loading: loading,
                                                currentUser: currentUser)
        let friendsVM = FriendsViewModel.configured(profileService: profileService,
                                                    friendsService: friendsService,
                                                    loading: loading,
                                                    currentUser: currentUser)
        let appNotificationsVM = AppNotificationsViewModel.configured(service: appNotificationsService, currentUser: currentUser)
        
        _habitVM = StateObject(wrappedValue: habitVM)
        _friendsVM = StateObject(wrappedValue: friendsVM)
        _appNotificationsVM = StateObject(wrappedValue: appNotificationsVM)
        
        self._selected = selected
    }
    
    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                NavigationBarView(selected: $selected) {
                    CreateHabitView() { habit in
                        Task { await habitVM.createHabit(habit) }
                    }.environmentObject(friendsVM)
                }
                .padding(.horizontal)
            }
        }.task {
            await habitVM.startListening()
            await friendsVM.startFriendsListener()
            await appNotificationsVM.startListening()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch selected {
        case .home:
            HomeView()
                .environmentObject(habitVM)
                .environmentObject(friendsVM)
                .environmentObject(appNotificationsVM)
//        case .stats:
//            StatsView()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.custom.background)
//            
//        case .chats:
//            ChatsView()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.custom.background)
        case .friends:
            FriendsListView(fullList: true)
                .environmentObject(friendsVM)
        case .settings:
            SettingsView()
        }
    }
}
