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
                    HomeView(
                        signOut: { Task { await authVM.signOut() } },
                        habitService: di.habitService,
                        authService: di.authService,
                        loading: loading
                    )
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
