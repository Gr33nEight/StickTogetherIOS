//
//  NotificationMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 21/03/2026.
//

import Foundation

enum NotificationMapper {
    static func toDomain(_ dto: NotificationDTO) -> Notification {
        Notification(
            id: dto.id,
            senderId: dto.senderId,
            receiverId: dto.receiverId,
            title: dto.title,
            body: dto.body,
            date: dto.date,
            isRead: dto.isRead,
            type: mapType(dto)
        )
    }
    
    static func toDTO(_ domain: Notification) -> NotificationDTO {
        NotificationDTO(
            id: domain.id,
            senderId: domain.senderId,
            receiverId: domain.receiverId,
            title: domain.title,
            body: domain.body,
            date: domain.date,
            isRead: domain.isRead,
            payload: mapPayload(domain),
            type: Int(domain.type.value)
        )
    }
    
    static func notificationStream(_ stream: AsyncThrowingStream<[NotificationDTO], any Error>) -> AsyncThrowingStream<[Notification], any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await dtos in stream {
                        continuation.yield(dtos.map(NotificationMapper.toDomain(_:)))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private static func mapType(_ dto: NotificationDTO) -> NotificationType {
        let habitId: String? = dto.payload?["habitId"]
        switch dto.type {
        case 0:
            return .systemMessage
        case 1:
            return .friendMessage
        case 2:
            return .habitInvite(habitId: habitId)
        case 3:
            return .friendRequest
        default:
            return .systemMessage
        }
    }
    
    private static func mapPayload(_ domain: Notification) -> [String: String]? {
        switch domain.type {
        case .systemMessage:
            return nil
        case .friendMessage:
            return nil
        case .habitInvite(let habitId):
            guard let habitId else { return nil }
            return ["habitId": habitId]
        case .friendRequest:
            return nil
        }
    }
}
