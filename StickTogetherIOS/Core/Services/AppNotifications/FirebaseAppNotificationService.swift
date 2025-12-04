//
//  FirebaseAppNotificationService.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/12/2025.
//

import FirebaseFirestore

actor FirebaseAppNotificationService: @preconcurrency AppNotificationsServiceProtocol {
    
    private let db = Firestore.firestore()
    private let collection = "appNotifications"
    
    private var listeners: [ListenerToken] = []
    
    func createAppNotification(_ appNotification: AppNotification) async throws {
        var notificationToSave = appNotification
        if notificationToSave.id == nil {
            notificationToSave.id = UUID().uuidString
        }
        
        try db.collection(collection)
            .document(notificationToSave.id!)
            .setData(from: notificationToSave)
    }
    
    func deleteAppNotification(_ appNotificationId: String) async throws {
        try await db.collection(collection)
            .document(appNotificationId)
            .delete()
    }
    
    func fetchAllAppNotifications(for userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection(collection)
            .whereField("receiverId", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: AppNotification.self) })
    }
    
    func listenToAppNotifications(for userId: String, update: @escaping ([AppNotification]) -> Void) -> any ListenerToken {
        let listener = db.collection(collection)
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else { return }
                let notifs = snapshot.documents.compactMap { try? $0.data(as: AppNotification.self) }
                update(notifs)
            }

        let token = FirestoreListenerToken(listener: listener)
        listeners.append(token)
        return token
    }
    
    private struct FirestoreListenerToken: ListenerToken {
        let listener: ListenerRegistration
        func remove() {
            listener.remove()
        }
    }
    
    func changeIsReadValue(_ appNotificationId: String, value: Bool) async throws {
        try await db.collection(collection)
            .document(appNotificationId)
            .setData(["isRead" : value], merge: true)
    }
}
