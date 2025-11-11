//
//  ContentView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct AppCoordinatorView: View {
    @EnvironmentObject var di: DIContainer
    @EnvironmentObject var loading: LoadingManager
    @Environment(\.showToastMessage) private var showToastMessage

    @StateObject private var authVM = AuthViewModel()
    var body: some View {
        NavigationView{
            Group {
                if authVM.isAuthenticated {
                    if let currentUser = authVM.currentUser,
                       let _ = currentUser.id {
                        HomeView(
                            signOut: { Task { await authVM.signOut() } },
                            currentUser: currentUser,
                            habitService: di.habitService,
                            friendsService: di.friendsService,
                            authService: di.authService,
                            loading: loading
                        )
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
        .onAppear {
            authVM.setup(authService: di.authService,
                         loading: loading,
                         toast: showToastMessage)
        }
    }
}
