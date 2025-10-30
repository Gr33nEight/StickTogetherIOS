//
//  CreateHabitViewInviteFriend.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateHabitView {
    var inviteFriend: some View {
        VStack {
            Toggle("Alone", isOn: $alone)
                .tint(Color.custom.primary)
                .padding(5)
            if !alone {
                Button {
                    // invite friend
                } label: {
                    Text("Invite a friend")
                }
                .customButtonStyle(.primary)
            }
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
    }
}
