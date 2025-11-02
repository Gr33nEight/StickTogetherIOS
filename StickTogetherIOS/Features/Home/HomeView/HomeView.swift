//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HabitViewModel
    @StateObject var userVm: UserViewModel

    @State var selectedDate: Date = Date()
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()

    let signOut: () -> Void

    init(signOut: @escaping () -> Void,
         habitService: HabitServiceProtocol,
         authService: any AuthServiceProtocol,
         loading: LoadingManager? = nil) {

        let userViewModel = UserViewModel(authService: authService, loading: loading)
        _userVm = StateObject(wrappedValue: userViewModel)

        let habitVM = HabitViewModel(service: habitService,
                                     authService: authService,
                                     userViewModel: userViewModel,
                                     loading: loading)
        _vm = StateObject(wrappedValue: habitVM)

        self.signOut = signOut
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
            await userVm.loadCurrentUser()
            await vm.loadUserHabits()
        }
    }
}
