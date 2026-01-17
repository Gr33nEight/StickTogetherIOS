// AppNotificationsViewModel.swift
// StickTogetherIOS

import SwiftUI

@MainActor
class AppNotificationsViewModel: ObservableObject {
    @Published var appNotifications: [AppNotification] = []
    
    private let service: AppNotificationsServiceProtocol
    private var listenerToken: ListenerToken?
    private var loadingManager: LoadingManager?
    private var currentUser: User
    
    var friendsRequestNotifications: [AppNotification] {
        return appNotifications.filter { $0.type == .friendRequest }
    }
    
    var friendsRequestNotReadNotificationsNum: Int {
        appNotifications.filter({ !$0.isRead && $0.type == .friendRequest }).count
    }
    
    init(service: AppNotificationsServiceProtocol,
         loading: LoadingManager? = nil,
         currentUser: User) {
        self.service = service
        self.loadingManager = loading
        self.currentUser = currentUser
    }
    
    deinit {
        listenerToken?.remove()
        listenerToken = nil
    }
    
    @MainActor
    func startListening() async {
        if listenerToken != nil { return }
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
                    return try await self.service.fetchAllAppNotifications(for: self.currentUser.safeID)
                }
                appNotifications = loaded
            } else {
                appNotifications = try await service.fetchAllAppNotifications(for: currentUser.safeID)
            }
            listenerToken = service.listenToAppNotifications(for: currentUser.safeID, update: { [weak self] newAppNotifications in
                Task { @MainActor in
                    self?.appNotifications = newAppNotifications
                }
            })
            
        } catch {
            print("Failed to fetch user app notifications: \(error)")
            appNotifications = []
        }
    }

    func sendAppNotification(_ notification: AppNotification) async {
        do {
            try await service.createAppNotification(notification)
        } catch {
            print("Failed to send app notification: \(error)")
        }
    }
    
    func deleteAppNotification(_ id: String?) async {
        guard let id else { return }
        do {
            try await service.deleteAppNotification(id)
        } catch {
            print("Failed to delete app notification: \(error)")
        }
    }
    
    func markAsRead(_ id: String?) async {
        guard let id else { return }
        do {
            try await service.changeIsReadValue(id, value: true)
        } catch {
            print("Failed to mark notification read: \(error)")
        }
    }
    
    func markAllAsRead() async {
        let ids = appNotifications.compactMap { $0.id }
        for id in ids {
            await markAsRead(id)
        }
    }
    
    func appNotificationId(by invitation: Invitation) async -> String? {
        if let id = appNotifications.first(
            where: {
                $0.senderId == invitation.senderId &&
                $0.receiverId == invitation.receiverId
            }
        )?.id {
            return id
        }

        return try? await service.getNotificationIdBy(
            receiverId: invitation.receiverId,
            senderId: invitation.senderId
        )
    }
}
