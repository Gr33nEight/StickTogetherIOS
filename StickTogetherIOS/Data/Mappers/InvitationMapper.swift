//
//  InvitationMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 17/03/2026.
//

import Foundation

enum InvitationMapper {
    static func toDomain(_ dto: InvitationDTO) -> Invitation {
        Invitation(id: dto.id, senderId: dto.senderId, receiverId: dto.receiverId)
    }
    
    static func toDTO(_ invitation: Invitation) -> InvitationDTO {
        InvitationDTO(id: invitation.id, senderId: invitation.senderId, receiverId: invitation.receiverId)
    }
    
    static func invitationStream(_ stream: AsyncThrowingStream<[InvitationDTO], any Error>) -> AsyncThrowingStream<[Invitation], Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await dtos in stream {
                        continuation.yield(dtos.map(InvitationMapper.toDomain(_:)))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
