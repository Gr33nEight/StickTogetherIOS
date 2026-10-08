//
//  FriendsView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 24/03/2026.
//

import SwiftUI

struct FriendsListView: View {
    @Environment(\.showToastMessage) var toastMessage
    @Environment(\.showModal) var showModal
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: FriendsListViewModel
    
    var onAddBuddy: (User) -> Void
    
    var body: some View {
        CustomView(title: "Friends List", dismissIcon: "xmark") {
            ZStack {
                if viewModel.friends.isEmpty {
                    VStack {
                        Spacer()
                        Text("You don't have any friends yet.")
                            .foregroundStyle(Color.custom.lightGrey)
                            .font(.mySubtitle)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }else{
                    ScrollView {
                        VStack {
                            ForEach(viewModel.friends) { friend in
                                ZStack(alignment: .trailing) {
                                    FriendsListCellView(friend: friend, invitedUser: $viewModel.invitedBuddy)
                                }
                            }
                        }.padding([.top, .horizontal])
                    }
                }
            }.frame(maxWidth: .infinity)
        } buttons: {
            Button {
                viewModel.handleInviteTap(onDismiss: onAddBuddy)
            } label: {
                Text(viewModel.invitedBuddy == nil ? "Invite a Friend" : "Add \(viewModel.invitedBuddy!.name) as a buddy")
            }.customButtonStyle(.primary)
            
        } icons: {}
            .task {
                await viewModel.startListening()
            }
            .onChange(of: viewModel.event) { _, event in
                guard let event else { return }
                
                switch event {
                case .dimsiss:
                    dismiss()
                case .closeModal:
                    showModal(.closeModal)
                case .showInviteModal:
                    showModal(.inviteFriend(invite: { email in
                        Task {
                            await viewModel.handleInvite(to: email)
                        }
                    }))
                case .showToastMessage(let message):
                    toastMessage(message)
                }
                
                viewModel.event = nil
            }
    }
}
