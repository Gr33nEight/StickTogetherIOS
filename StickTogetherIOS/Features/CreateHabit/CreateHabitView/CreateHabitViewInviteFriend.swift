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
                    showFriendsList.toggle()
                } label: {
                    Text("Invite a friend")
                }.customButtonStyle(.primary)
            }

//            if let hid = id, !alone {
//                let inviteText = "Hey! I just created a new habit on StickTogether — join me and let’s stay consistent together 💪"
//                if let link = URL(string: "sticktogether://habit/\(hid)") {
//                    ShareLink(item: link, preview: SharePreview(inviteText, image: Image(.logo))) {
//                        
//                    }
//                }
//            }
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
    }
}
