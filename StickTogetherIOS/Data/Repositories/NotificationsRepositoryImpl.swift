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
    
    func getNotification(byReceiver id: String) async throws -> Notification {
        let query = FirestoreQuery().isEqual(.field("receiverId"), .string(id))
        let dtos = try await firestoreClient.fetch(NotificationEndpoint.self, query: query)
        guard let dto = dtos.first else { throw NotificationError.notificationNotFound }
        return NotificationMapper.toDomain(dto)
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
}

enum NotificationError: Error {
    case notificationNotFound
}
