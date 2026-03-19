//
//  InvitationReceivedView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//
import SwiftUI

struct InvitationReceivedView: View {
    let invitation: Invitation
    let accept: () -> Void
    let decline: () -> Void
    var friend: User?
    var body: some View {
        ZStack {
            if let friend = friend {
                HStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.custom.text)
                        Text("🙍‍♂️")
                            .font(.system(size: 40))
                            .shadow(color: .black.opacity(0.5), radius: 5)
                            .padding(10)
                    }.frame(minWidth: 80, minHeight: 80)
                        .scaledToFit()
                    VStack(alignment: .leading, spacing: 3) {
                        Text(friend.name)
                            .font(.myBody)
                            .foregroundStyle(Color.custom.text)
                        Text(friend.email)
                            .font(.customAppFont(size: 12, weight: .medium))
                            .foregroundStyle(Color.custom.primary)
                        HStack(spacing: 10) {
                            Button {
                                accept()
                            } label: {
                                Text("Accept")
                                    .padding(-8)
                            }.customButtonStyle(.primary)
                            Button {
                                decline()
                            } label: {
                                Text("Decline")
                                    .padding(-8)
                            }.customButtonStyle(.secondary)
                        }.padding(.top, 5)
                    }.multilineTextAlignment(.leading)
                        .layoutPriority(1)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.background)
                )
            }
        }
    }
}

