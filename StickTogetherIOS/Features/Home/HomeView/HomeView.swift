//
//  HomeView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HabitViewModel
    
    @State var selectedDate: Date = Date()
    @State var pageIndex: Int = 0
    @State var baseWeekAnchor: Date = Date()
    
    let currentUser: User
    let signOut: () -> Void

    init(signOut: @escaping () -> Void, currentUser: User, habitService: HabitServiceProtocol, authService: any AuthServiceProtocol) {
        _vm = StateObject(wrappedValue: HabitViewModel(service: habitService, authService: authService))
        self.signOut = signOut
        self.currentUser = currentUser
    }

    var body: some View {
        VStack(spacing: 30) {
            header
            calendar
            content
        }
        .background(Color.custom.background)
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
        .task {
            await vm.loadUserHabits() // initial load / listener
        }
    }
}
