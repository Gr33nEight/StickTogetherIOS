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
struct StickTogetherIOSApp: App {
    @StateObject var diContainer = DIContainer()
    @StateObject var loading = LoadingManager()
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntry()
                .confirmation()
                .modal()
                .customToastMessage()
                .environmentObject(diContainer)
                .environmentObject(loading)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
