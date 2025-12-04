//
//  ContentView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject var di: DIContainer
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var loading: LoadingManager
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Environment(\.showToastMessage) private var showToastMessage
    
    @State private var selectedView: NavigationDestinations = .home
    
    var body: some View {
        NavigationView{
            Group {
                if authVM.isAuthenticated {
                    if let user = profileVM.currentUser, user.id != nil {
                        NavigationContainer(
                            selected: $selectedView,
                            habitService: di.habitService,
                            friendsService: di.friendsService,
                            profileService: di.profileService,
                            appNotificationsService: di.appNotificationsService,
                            currentUser: user
                        )
                            .environmentObject(authVM)
                            .environmentObject(profileVM)
                            .environmentObject(loading)
                            .onAppear {
                                selectedView = .home
                            }
                    }else{
                        ProgressView()
                            .tint(.accent)
                    }
                } else {
                    LogInView(vm: authVM)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
