//
//  NotificationsViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 23/03/2026.
//

import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private var allNotifications: [Notification] = []

    @Published private(set) var error: String?
    
    private let currentUserId: String
    private var notificationsTask: Task<Void, Never>?
    
    private let listenToUserNotifications: ListenToNotificationsUseCase
    private let markAsReadUseCase: MarkAsReadUseCase
    
    var userNotifications: [Notification] {
        allNotifications.filter({$0.type != .friendRequest})
    }
    
    var numberOfUserNotReadNotifications: Int {
        userNotifications.filter({!$0.isRead}).count
    }
    
    var numberOfUserNotReadInvitations: Int {
        allNotifications.filter({!$0.isRead && $0.type == .friendRequest}).count
    }
    
    init(
        currentUserId: String,
        listenToUserNotifications: ListenToNotificationsUseCase,
        markAsReadUseCase: MarkAsReadUseCase
    ) {
        self.currentUserId = currentUserId
        self.listenToUserNotifications = listenToUserNotifications
        self.markAsReadUseCase = markAsReadUseCase
    }
    
    func startListeningToUserNotifications() {
        stopListeningToUserNotifications()
        notificationsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await listenToUserNotifications.stream(for: currentUserId)
                for try await notifications in stream {
                    self.allNotifications = notifications
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func stopListeningToUserNotifications() {
        notificationsTask?.cancel()
        notificationsTask = nil
    }
    
    func markAsRead(_ id: String?) async {
        guard let id else { return }
        do {
            try await markAsReadUseCase.execute(for: id)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func markAllAsRead() async {
        let ids = userNotifications.compactMap { $0.id }
        for id in ids {
            await markAsRead(id)
        }
    }
    
}
