//
//  ContentView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct AppCoordinatorView: View {
    @EnvironmentObject var di: DIContainer
    @StateObject private var authVM = AuthViewModel()
    var body: some View {
        NavigationView{
            Group {
                if authVM.isAuthenticated {
                    Text("Authenticated")
                } else {
                    LogInView(vm: authVM)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }.onAppear {
            authVM.setup(authService: di.authService)
        }
    }
}
