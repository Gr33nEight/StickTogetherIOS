//
//  PushManager.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/12/2025.
//

import FirebaseMessaging

final class PushManager: NSObject, ObservableObject, MessagingDelegate {
    static let shared = PushManager()
    
    @Published private(set) var currentToken: String?
    
    private override init() {
        super.init()
    }
    
    func configure() {
        Messaging.messaging().delegate = self
    }
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        
        print("📲 FCM token:", token)

        currentToken = token
        saveTokenToLocalStorage(token)
    }
    
    private func saveTokenToLocalStorage(_ token: String) {
        UserDefaults.standard.set(token, forKey: "fcm_token")
    }
}
