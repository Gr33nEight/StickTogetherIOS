//
//  NotificationsRepositoryImpl.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

final class NotificationsRepositoryImpl: NotificationsRepository {
    private let firestoreClient: FirestoreClient
    private let transactionClient: FirestoreTransactionClient
    
    init(firestoreClient: FirestoreClient, transactionClient: FirestoreTransactionClient) {
        self.firestoreClient = firestoreClient
        self.transactionClient = transactionClient
    }
    
    func createNotification(_ notification: Notification) async throws {
        let dto = NotificationMapper.toDTO(notification)
        let docId = try await firestoreClient.create(dto, for: NotificationEndpoint.self)
        try await firestoreClient.setData(dto, for: NotificationEndpoint.self, id: docId, merge: false)
    }
    
    func getNotification(by id: String) async throws -> Notification {
        let dto = try await firestoreClient.fetchDocument(NotificationEndpoint.self, id: .init(value: id))
        return NotificationMapper.toDomain(dto)
    }
    
    func getNotification(byReceiver id: String, and senderId: String) async throws -> Notification {
        let query = FirestoreQuery()
            .isEqual(.field("receiverId"), .string(id))
            .isEqual(.field("senderId"), .string(senderId))
            .isEqual(.field("type"), .int(3))
        let dtos = try await firestoreClient.fetch(NotificationEndpoint.self, query: query)
        guard let dto = dtos.first else { throw NotificationError.notificationNotFound }
        
        return NotificationMapper.toDomain(dto)
    }
    
    func getNotifications(byReceiver id: String) async throws -> [Notification] {
        let query = FirestoreQuery().isEqual(.field("receiverId"), .string(id))
        let dtos = try await firestoreClient.fetch(NotificationEndpoint.self, query: query)
        return dtos.map(NotificationMapper.toDomain(_:))
    }
    
    func deleteNotification(by notificationId: String) async throws {
        try await firestoreClient.delete(NotificationEndpoint.self, id: FirestoreDocumentID(value: notificationId))
    }

    func deleteNotification(transactionContext: TransactionContext, by notificationId: String) throws {
        try transactionClient.delete(NotificationEndpoint.self, id: FirestoreDocumentID(value: notificationId), transactionContext: transactionContext)
    }
    
    func listenToNotifications(for userId: String) -> AsyncThrowingStream<[Notification], any Error> {
        let query = FirestoreQuery().isEqual(.field("receiverId"), .string(userId))
        let stream = firestoreClient.listen(NotificationEndpoint.self, query: query)
        return NotificationMapper.notificationStream(stream)
    }
    
    func markNotificationAsRead(by notificationId: String) async throws {
        try await firestoreClient.updateData(for: NotificationEndpoint.self, id: .init(value: notificationId), ["isRead" : .set(true)])
    }
}

enum NotificationError: Error {
    case notificationNotFound
}
