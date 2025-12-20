//
//  NavigationStackContentView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/12/2025.
//

import SwiftUI

struct NavigationStackContentView: View {
    @State private var path = [Route]()
    @State private var selectedView: NavigationDestinations = .home
    
    @StateObject private var habitVM: HabitViewModel
    @StateObject private var friendsVM: FriendsViewModel
    @StateObject private var appNotificationsVM: AppNotificationsViewModel
    
    init(
        habitService: HabitServiceProtocol,
         friendsService: FriendsServiceProtocol,
         profileService: ProfileServiceProtocol,
         appNotificationsService: AppNotificationsServiceProtocol,
         currentUser: User,
         loading: LoadingManager? = nil
    ) {
        
        let habitVM = HabitViewModel.configured(service: habitService,
                                                loading: loading,
                                                currentUser: currentUser)
        let friendsVM = FriendsViewModel.configured(profileService: profileService,
                                                    friendsService: friendsService,
                                                    currentUser: currentUser)
        let appNotificationsVM = AppNotificationsViewModel.configured(service: appNotificationsService, loading: loading, currentUser: currentUser)
        
        _habitVM = StateObject(wrappedValue: habitVM)
        _friendsVM = StateObject(wrappedValue: friendsVM)
        _appNotificationsVM = StateObject(wrappedValue: appNotificationsVM)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            NavigationContainer(selected: $selectedView)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home: NavigationContainer(selected: $selectedView)
                    case .habit(let container): HabitView(habit: container.habit, selectedDate: container.selectedDate, friends: container.friends)
                    case .createHabit: CreateHabitView()
                    case .notifications: NotificationView()
                    }
                }
        }.environmentObject(habitVM)
        .environmentObject(friendsVM)
        .environmentObject(appNotificationsVM)
        .environment(\.navigate) { type in
            switch type {
            case .push(let route):
                path.append(route)
            case .unwind(let route):
                if route == .home {
                    path = []
                }else{
                    guard let index = path.firstIndex(where: {$0 == route}) else { return }
                    path = Array(path.prefix(upTo: index + 1))
                }
            }
        }
        .task {
            await habitVM.startListening()
            await friendsVM.startFriendsListener()
            await appNotificationsVM.startListening()
            selectedView = .home
        }
    }
}
