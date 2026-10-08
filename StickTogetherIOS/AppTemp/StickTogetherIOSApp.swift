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
    let container = AppContainer()
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.configure()
        PushManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            container.makeAppEntry()
                .confirmation()
                .modal()
                .customToastMessage()
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
