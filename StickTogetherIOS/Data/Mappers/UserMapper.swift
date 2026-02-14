//
//  UserMapper.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

enum UserMapper {
    static func toDomain(_ user: UserDTO) -> User {
        User(
            id: user.id,
            name: user.name,
            email: user.email,
            friendsIds: user.friendsIds,
            icon: user.icon,
            language: user.language,
            theme: user.theme,
            mainHabitType: user.mainHabitType
        )
    }
    static func toDTO(_ dto: User) -> UserDTO {
        UserDTO(
            id: dto.id,
            name: dto.name,
            email: dto.email,
            friendsIds: dto.friendsIds,
            icon: dto.icon,
            language: dto.language,
            theme: dto.theme,
            mainHabitType: dto.mainHabitType
        )
    }
}
