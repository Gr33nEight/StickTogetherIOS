//
//  AppNotificationViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/12/2025.
//

import SwiftUI

class AppNotificationsViewModel: ObservableObject {
    @Published var appNotifications: [AppNotification] = []
    
    private let service: AppNotificationsServiceProtocol
    private var listenerToken: ListenerToken?
    private var loadingManager: LoadingManager?
    private var currentUser: User
    
    init(service: AppNotificationsServiceProtocol,
         loading: LoadingManager? = nil,
         currentUser: User) {
        self.service = service
        self.loadingManager = loading
        self.currentUser = currentUser
    }
    
    @MainActor
    func startListening() async {
        if listenerToken != nil {
            return
        }
        await loadUserAppNotifications()
    }
    
    static func configured(service: AppNotificationsServiceProtocol,
                           loading: LoadingManager? = nil,
                           currentUser: User) -> AppNotificationsViewModel {
        return AppNotificationsViewModel(service: service, loading: loading, currentUser: currentUser)
    }
    
    private func loadUserAppNotifications() async {
        guard listenerToken == nil else { return }
        
        do {
            if let loader = loadingManager {
                let loaded: [AppNotification] = try await loader.run {
                    try await self.service.fetchAllAppNotifications(for: self.currentUser.safeID)
                }
                appNotifications = loaded
            }else{
                appNotifications = try await service.fetchAllAppNotifications(for: currentUser.safeID)
            }
            
            listenerToken = service.listenToAppNotifications(for: currentUser.safeID, update: { [weak self] newAppNotifications in
                self?.appNotifications = newAppNotifications
            })
            
        } catch {
            print("Failed to fetch user app notifications: \(error)")
            appNotifications = []
        }
    }

    func sendAppNotification(_ notification: AppNotification) async {
        do {
            if let loader = loadingManager {
                try await loader.run { [self] in
                    try await service.createAppNotification(notification)
                }
            }else{
                 try await service.createAppNotification(notification)
            }
        } catch {
            print("Failed to send app notification: \(error)")
        }
    }
    
    func deleteAppNotification(_ id: String?) async {
        guard let id else { return }
        
        do {
            if let loader = loadingManager {
                try await loader.run { [self] in
                    try await service.deleteAppNotification(id)
                }
            }else{
                 try await service.deleteAppNotification(id)
            }
        } catch {
            print("Failed to delete app notification: \(error)")
        }
    }
    
    func markAsRead(_ id: String?) async {
        guard let id else { return }
        
        do {
            if let loader = loadingManager {
                try await loader.run { [self] in
                    try await service.changeIsReadValue(id, value: true)
                }
            }else{
                try await service.changeIsReadValue(id, value: true)
            }
        } catch {
            print("Failed to delete app notification: \(error)")
        }
    }
}
