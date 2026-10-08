//
//  FriendsListCellView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//
import SwiftUI

struct FriendsListCellView: View {
    let friend: User
    @Binding var invitedUser: User?
    private var invited: Bool {
        invitedUser?.id == friend.id
    }
    var body: some View {
        HStack(spacing: 15) {
            Text("🙍‍♂️")
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.custom.text)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(friend.name)
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                Text(friend.email)
                    .font(.customAppFont(size: 12, weight: .medium))
                    .foregroundStyle(invited ? Color.custom.background : Color.custom.primary)
            }.multilineTextAlignment(.leading)
            Spacer()
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(invited ? Color.custom.primary : Color.custom.background)
            )
            .onTapGesture {
                if invited {
                    invitedUser = nil
                }else{
                    invitedUser = friend
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
    }
}
