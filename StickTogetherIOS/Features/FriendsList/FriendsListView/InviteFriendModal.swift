//
//  InviteFriendModal.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 04/11/2025.
//
import SwiftUI

struct InviteFriendModal: View {
    @State private var email: String = ""
    let invite: (String) -> Void
    var body: some View {
        VStack {
            Text("Invite a friend")
                .font(.mySubtitle)
            TextField("Enter friend's email", text: $email)
                .font(.myBody)
                .padding(.vertical, 10)
                .autocorrectionDisabled()
                .textCase(.lowercase)
            Button {
                invite(email.lowercased())
            } label: {
                Text("Sent invite")
            }.customButtonStyle(.primary)

        }
    }
}
