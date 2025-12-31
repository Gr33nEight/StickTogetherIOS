//
//  AppDelegateAdaptor.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/12/2025.
//

import FirebaseMessaging
import SwiftUI

class AppDelegateAdaptor: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("📲 APNs token forwarded to FCM")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications:", error)
    }
}
