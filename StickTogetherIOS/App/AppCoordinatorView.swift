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
    
    var body: some View {
        NavigationView{
            Group {
                if authVM.isAuthenticated {
                    if let user = profileVM.currentUser, user.id != nil {
                        NavigationStackContentView(
                            habitService: di.habitService,
                            friendsService: di.friendsService,
                            profileService: di.profileService,
                            appNotificationsService: di.appNotificationsService,
                            currentUser: profileVM.safeUser,
                            loading: loading, authenticatedAppContainer: AuthenticatedAppContainer(userId: user.safeID)
                        )
                    }else{
                        LoadingView()
                    }
                } else {
                    LogInView(vm: authVM)
                        .navigationBarBackButtonHidden(true)
                        .onAppear {
                            loading.stop()
                        }
                }
            }
        }
    }
}
