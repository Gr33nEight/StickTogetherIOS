//
//  FriendsListView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 03/11/2025.
//

import SwiftUI
import UniformTypeIdentifiers

enum FriendsListType: CaseIterable {
    case allFriends, invitationSent, invitationReceived
    
    var text: String {
        switch self {
        case .allFriends: return "All\nFriends"
        case .invitationSent: return "Invitation\nSent"
        case .invitationReceived: return "Invitation\nReceived"
        }
    }
}

struct FriendsListView: View {
    var fullList: Bool = false
    @ObservedObject var friendsVM: FriendsViewModel
    @State var pickedFriendsListType: FriendsListType = .allFriends
    let currentUser: User
    
    @State var invitedBuddy: User? = nil
    @Namespace var friendsListAnimation
    
    @Environment(\.showToastMessage) var toastMessage
    @Environment(\.showModal) var showModal
    @Environment(\.dismiss) var dismiss
    
    @State private var removingStarted = false
    
    var onDismiss: ((User) -> Void)?
    
    var body: some View {
        CustomView(title: "Friends List", dismissIcon: fullList ? "chevron.left" : "xmark") {
            VStack {
                if fullList {
                    HStack(spacing: 0) {
                        ForEach(FriendsListType.allCases, id:\.self) { type in
                            Button {
                                pickedFriendsListType = type
                            } label: {
                                ZStack {
                                    if pickedFriendsListType == type {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.custom.primary)
                                            .matchedGeometryEffect(id: "friendsList-bg", in: friendsListAnimation)
                                    }
                                    Text(type.text)
                                        .font(.customAppFont(size: 13, weight: .bold))
                                        .foregroundColor(pickedFriendsListType == type ? Color.custom.text : Color(.systemGray))
                                        .frame(width: (UIScreen.main.bounds.size.width-60)/3, height: 45)
                                }
                            }
                        }
                    }.animation(.bouncy, value: pickedFriendsListType)
                        .frame(height: 60)
                        .padding()
                    switch pickedFriendsListType {
                    case .allFriends:
                        allFriendsList
                    case .invitationSent:
                        invitationList(.invitationSent)
                    case .invitationReceived:
                        invitationList(.invitationReceived)
                    }
                }else{
                    allFriendsList
                }
            }
            
        } buttons: {
            Button {
                if let buddy = invitedBuddy,
                   let onDismiss = onDismiss {
                    onDismiss(buddy)
                    dismiss()
                }
                
                if invitedBuddy == nil || fullList {
                    showModal(.inviteFriend(invite: { email in
                        Task {
                            if friendsVM.friends.contains(where: {$0.email == email}) {
                                toastMessage(.info("This user is already your friend!"))
                            }else if email == currentUser.email {
                                toastMessage(.info("You can't invite yourself!"))
                            }else {
                                let result = await friendsVM.sendInvitation(to: email)
                                if let errorMessage = result.errorMessage {
                                    toastMessage(.failed(errorMessage))
                                }else{
                                    showModal(.closeModal)
                                }
                            }
                        }
                    }))
                }
            } label: {
                Text((invitedBuddy == nil || fullList) ? "Invite a Friend" : "Add \(invitedBuddy!.name) as a buddy")
            }.customButtonStyle(.primary)
            
        } icons: {
            Button {
                removingStarted.toggle()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(removingStarted ? Color.custom.red : Color.custom.primary)
            }
            
        }.animation(.easeInOut, value: removingStarted)
            .task {
                if fullList {
                    let result = await friendsVM.fetchAllInvitation()
                    if let errorMessage = result.errorMessage {
                        toastMessage(.failed(errorMessage))
                    }
                }
            }
            .onDisappear {
                friendsVM.stopFriendsListener()
            }
    }
}


extension FriendsListView {
    var allFriendsList: some View {
        ZStack {
            if friendsVM.friends.isEmpty {
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
                        ForEach(friendsVM.friends) { friend in
                            if let uid = friend.id {
                                ZStack(alignment: .trailing) {
                                    FriendCellView(friend: friend, invitedUser: $invitedBuddy, fullList: fullList)
                                        .offset(x: removingStarted ? -65 : 0)
                                    Button {
                                        removingStarted.toggle()
                                        Task { await friendsVM.removeFromFriendsList(userId: uid)}
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(Color.custom.text)
                                            .padding(15)
                                            .background(
                                                Circle()
                                                    .fill(Color.custom.red)
                                            )
                                    }.offset(x: removingStarted ? 0 : 65)
                                    
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
        let list: [Invitation] = type == .invitationReceived ? friendsVM.invitationReceived : friendsVM.invitationSent
        ZStack {
            if let friends = friendsVM.friendsFromInvitation[type],
               friends.isEmpty {
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
                        ForEach(list) { invitation in
                            ZStack(alignment: .trailing) {
                                if let invitationId = invitation.id {
                                    ZStack {
                                        let friend = friendsVM.friendsFromInvitation[type]?[invitationId]
                                        if type == .invitationReceived {
                                            InvitationReceivedView(invitation: invitation, accept: {
                                                Task {
                                                    let result = await friendsVM.acceptInvitation(invitation: invitation)
                                                    if let errorMessage = result.errorMessage {
                                                        toastMessage(.failed(errorMessage))
                                                    }
                                                }
                                            }, decline: {
                                                Task {
                                                    let result = await friendsVM.declineInvitation(with: invitationId)
                                                    if let errorMessage = result.errorMessage {
                                                        toastMessage(.failed(errorMessage))
                                                    }
                                                }
                                            }, friend: friend)
                                        }else{
                                            InvitationSentView(invitation: invitation, cancel: {
                                                Task {
                                                    let result = await friendsVM.cancelInvitation(with: invitationId)
                                                    if let errorMessage = result.errorMessage {
                                                        toastMessage(.failed(errorMessage))
                                                    }
                                                }
                                            }, friend: friend)
                                        }
                                    }.offset(x: removingStarted ? -65 : 0)
                                    Button {
                                        removingStarted.toggle()
                                        Task { await friendsVM.cancelInvitation(with: invitationId) }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(Color.custom.text)
                                            .padding(15)
                                            .background(
                                                Circle()
                                                    .fill(Color.custom.red)
                                            )
                                    }.offset(x: removingStarted ? 0 : 65)
                                }
                                
                            }
                        }
                    }.padding([.top, .horizontal])
                }
            }
        }
    }
}

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

struct InvitationSentView: View {
    let invitation: Invitation
    let cancel: () -> Void
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
                        Text("Waiting for response")
                            .font(.customAppFont(size: 12, weight: .medium))
                            .foregroundStyle(Color.custom.primary)
                        Button(action: { cancel() }) {
                            Text("Cancel")
                                .padding(-8)
                        }.customButtonStyle(.primary)
                            .padding(.top, 5)
                    }.multilineTextAlignment(.leading)
                        .layoutPriority(1)
                    Spacer()
                }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.custom.background)
                    )
            }
        }
    }
}
