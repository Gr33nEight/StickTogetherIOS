//
//  FriendsListView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//


import SwiftUI
import UniformTypeIdentifiers


struct FriendsView: View {
    @StateObject var viewModel: FriendsViewModel
    @Namespace var friendsListAnimation
    
    @Environment(\.showToastMessage) var toastMessage
    @Environment(\.showModal) var showModal
    @Environment(\.dismiss) var dismiss
    
    @State private var removingStarted = false
    
    var onDismiss: ((User) -> Void)?
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            }else{
                CustomView(title: "Friends", dismissIcon: "") {
                    VStack {
                        HStack(spacing: 0) {
                            ForEach(FriendsListType.allCases, id:\.self) { type in
                                Button {
                                    viewModel.pickedFriendsListType = type
                                } label: {
                                    ZStack {
                                        if viewModel.pickedFriendsListType == type {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.custom.primary)
                                                .matchedGeometryEffect(id: "friendsList-bg", in: friendsListAnimation)
                                        }
                                        Text(type.text)
                                            .font(.customAppFont(size: 13, weight: .bold))
                                            .foregroundColor(viewModel.pickedFriendsListType == type ? Color.custom.text : Color(.systemGray))
                                            .customBadge(number: type == .invitationReceived ? viewModel.numberOfReceivedInvitations : 0, offset: CGPoint(x: 6, y: -2))
                                            .frame(width: (UIScreen.main.bounds.size.width-60)/3, height: 45)
                                    }
                                }
                            }
                        }.animation(.bouncy, value: viewModel.pickedFriendsListType)
                            .frame(height: 60)
                            .padding()
                        switch viewModel.pickedFriendsListType {
                        case .allFriends:
                            allFriendsList
                        case .invitationSent:
                            invitationList(.invitationSent)
                        case .invitationReceived:
                            EmptyView()
                            invitationList(.invitationReceived)
                        }
                    }
                    
                } buttons: {
                    Button {
                        viewModel.handleInviteTap()
                    } label: {
                        Text("Invite a Friend")
                    }.customButtonStyle(.primary)
                    
                } icons: {
                    Button {
                        removingStarted.toggle()
                    } label: {
                        Image(.trash)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .tint(removingStarted ? Color.custom.red : Color.custom.primary)
                    }
                    
                }.padding(.bottom, 60)
            }
        }
            .background(Color.custom.background)
        .animation(.easeInOut, value: removingStarted)
            .task {
                viewModel.startListening()
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


extension FriendsView {
    var allFriendsList: some View {
        ZStack {
            if viewModel.visibleFriends.isEmpty {
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
                        ForEach(viewModel.visibleFriends) { friend in
                            if let uid = friend.id {
                                ZStack(alignment: .trailing) {
                                    FriendCellView(friend: friend)
                                        .offset(x: removingStarted ? -65 : 0)
                                    Button {
                                        removingStarted.toggle()
                                        Task { await viewModel.removeFriend(by: uid) }
                                    } label: {
                                        Image(.trash)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 24)
                                            .foregroundStyle(Color.custom.text)
                                            .padding(15)
                                            .background(
                                                Circle()
                                                    .fill(Color.custom.red)
                                            )
                                    }.offset(x: removingStarted ? 0 : 75)
                                    
                                }
                            }
                        }
                    }.padding([.top, .horizontal])
                }
            }
        }.frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func invitationList(_ type: FriendsListType) -> some View {
        ZStack {
            if viewModel.visibleInvitations.isEmpty {
                VStack {
                    Spacer()
                    Text("You don't have any\n\(type == .invitationReceived ? "invitations" : "sent invitations") yet.")
                        .foregroundStyle(Color.custom.lightGrey)
                        .font(.mySubtitle)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack {
                        ForEach(viewModel.visibleInvitations) { invitation in
                            ZStack(alignment: .trailing) {
                                ZStack {
                                    if type == .invitationReceived {
                                        InvitationReceivedView(invitation: invitation.invitation, accept: {
                                            Task { await viewModel.acceptInvitation(with: invitation.id) }
                                        }, decline: {
                                            Task { await viewModel.declineInvitation(with: invitation.id) }
                                        }, friend: invitation.user)
                                    }else{
                                        InvitationSentView(invitation: invitation.invitation, cancel: {
                                            Task { await viewModel.removeInvitation(with: invitation.id) }
                                        }, friend: invitation.user)
                                    }
                                }.offset(x: removingStarted ? -65 : 0)
                                Button {
                                    removingStarted.toggle()
                                    Task { await viewModel.removeInvitation(with: invitation.id) }
                                } label: {
                                    Image(.trash)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                        .foregroundStyle(Color.custom.text)
                                        .padding(15)
                                        .background(
                                            Circle()
                                                .fill(Color.custom.red)
                                        )
                                }.offset(x: removingStarted ? 0 : 75)
                            }
                        }
                    }.padding([.top, .horizontal])
                }
            }
        }
    }
}
