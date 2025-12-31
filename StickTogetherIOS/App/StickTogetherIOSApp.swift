//
//  StickTogetherIOSApp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

@main
struct StickTogetherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegateAdaptor.self) var appDelegate
    
    @StateObject private var di: DIContainer = DIContainer()
    @StateObject private var loading = LoadingManager()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var profileVM: ProfileViewModel

    init() {
        FirebaseApp.configure()
        NotificationManager.shared.configure()
        PushManager.shared.configure()
        
        let profileService = FirebaseProfileService()
        _profileVM = StateObject(wrappedValue: ProfileViewModel(profileService: profileService))
    }

    var body: some Scene {
        WindowGroup {
            AppEntry(di: di)
                .confirmation()
                .modal()
                .customToastMessage()
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environmentObject(loading)
                .environmentObject(authVM)
                .environmentObject(profileVM)
                .onAppear {
                    authVM.setup(authService: di.authService, loading: loading)
                }
        }
    }
}
