//
//  NotificationRepository.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 20/03/2026.
//

import Foundation

protocol NotificationsRepository {
    func createNotification(_ notification: Notification) async throws
    func getNotification(by id: String) async throws -> Notification
    func getNotification(byReceiver id: String, and senderId: String) async throws -> Notification
    func getNotifications(byReceiver id: String) async throws -> [Notification]
    func deleteNotification(by notificationId: String) async throws
    func deleteNotification(transactionContext: TransactionContext, by notificationId: String) throws
    func listenToNotifications(for userId: String) -> AsyncThrowingStream<[Notification], Error>
    func markNotificationAsRead(by notificationId: String) async throws
}
