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
            HStack {
                Text("Habit Type")
                Spacer()
                Picker("", selection: $type) {
                    ForEach(HabitType.allCases, id: \.self) { type in
                        Text(type.text).tag(type)
                    }
                }.tint(Color.custom.text)
                    .pickerStyle(.menu)
                    .font(.myBody)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, type != .alone ? 8 : 0)
            if type != .alone {
                if let buddy = buddy {
                    HStack(spacing: 15) {
                        Text(buddy.icon)
                            .font(.system(size: 23))
                            .shadow(color: .black.opacity(0.5), radius: 5)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.custom.text)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(buddy.name)
                                .font(.myBody)
                                .foregroundStyle(Color.custom.text)
                            Text(buddy.email)
                                .font(.customAppFont(size: 12, weight: .medium))
                                .foregroundStyle(Color.custom.primary)
                        }.multilineTextAlignment(.leading)
                        Spacer()
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            self.buddy = nil
                        } label: {
                            Image(systemName: "minus")
                                .font(.mySubtitle)
                                .foregroundStyle(Color.custom.primary)
                                .padding()
                                .background { Color.custom.grey }
                        }
                    }
                }else{
                    Button {
                        showFriendsList.toggle()
                    } label: {
                        Text("Invite a friend")
                    }.customButtonStyle(.primary)
                }
            }
        }.customCellViewModifier()
            .animation(.default, value: setReminder)
//            .onChange(of: alone) { oldValue, newValue in
//                if newValue {
//                    self.buddy = nil
//                }
//            }
    }
}

//#Preview {
//    CreateHabitView(friendsVM: FriendsViewModel(authService: MockAuthService(), friendsService: MockFriendsService(), currentUser: User(name: "Natan", email: "natan")), currentUser: User(name: "Natan", email: "natan"), createHabit: { _ in
//        
//    }).preferredColorScheme(.dark)
//}
