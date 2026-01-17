//
//  AppNotificationsServiceProtocol.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/12/2025.
//

import SwiftUI

protocol AppNotificationsServiceProtocol {
    func createAppNotification(_ appNotification: AppNotification) async throws
    func deleteAppNotification(_ appNotificationId: String) async throws
    func fetchAllAppNotifications(for userId: String) async throws -> [AppNotification]
    func listenToAppNotifications(for userId: String, update: @escaping ([AppNotification]) -> Void) -> ListenerToken
    func changeIsReadValue(_ appNotificationId: String, value: Bool) async throws
    func getNotificationIdBy(receiverId: String, senderId: String) async throws -> String?
}
