//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.confirm) var confirm
    
    @StateObject var habitVM: HabitViewModel
    @StateObject var friendsVM: FriendsViewModel

    @State var selectedDate: Date = Date()
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()

    let signOut: () -> Void
    let currentUser: User

    init(signOut: @escaping () -> Void,
         currentUser: User,
         habitService: HabitServiceProtocol,
         friendsService: FriendsServiceProtocol,
         authService: any AuthServiceProtocol,
         loading: LoadingManager? = nil) {

        let habitVM = HabitViewModel(service: habitService,
                                     authService: authService,
                                     loading: loading)
        _habitVM = StateObject(wrappedValue: habitVM)
        
        let friendsVM = FriendsViewModel(authService: authService, friendsService: friendsService,
                                     loading: loading)
        _friendsVM = StateObject(wrappedValue: friendsVM)

        self.signOut = signOut
        self.currentUser = currentUser
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
        .task {
            await habitVM.loadUserHabits()
        }
    }
}
