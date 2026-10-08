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

        // Snapshot callbacks decode Firestore documents before publishing them.
        // Keep that work off the main queue so listener updates cannot block
        // tab transitions while the UI is rendering.
        let firestore = Firestore.firestore()
        let firestoreSettings = firestore.settings
        firestoreSettings.dispatchQueue = DispatchQueue(label: "com.sticktogether.firestore-callbacks")
        firestore.settings = firestoreSettings

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
