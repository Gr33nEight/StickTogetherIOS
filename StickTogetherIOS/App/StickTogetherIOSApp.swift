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

@main
struct StickTogetherIOSApp: App {
    @StateObject var diContainer = DIContainer()
    @StateObject var loading = LoadingManager()
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.configure()
        Task {
            NotificationManager.shared.requestAuthorization { granted in
                print("Notification allowed:", granted)
            }
        }
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
        }
    }
}
