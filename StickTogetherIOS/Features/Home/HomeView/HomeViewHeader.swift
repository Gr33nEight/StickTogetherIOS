//
//  HomeViewHeader.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

extension HomeView {
    var header: some View {
        HStack {
            Text("\(Date().timeOfDayGreeting),\n\(currentUser.name.capitalized) 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            ZStack {
                Text(currentUser.icon)
                    .font(.system(size: 25))
                    .shadow(color: .black.opacity(0.5), radius: 5)
            }.padding(10)
                .background(
                    Circle()
                        .fill(Color.custom.text)
                )
                .onTapGesture {
                    isEmojiPickerPresented.toggle()
                }
        }.foregroundStyle(Color.custom.text)
            .padding([.top, .horizontal], 20)
            .onChange(of: selectedEmoji?.emoji) { _, emoji in
                if let emojiString = emoji {
                    var user = currentUser
                    user.icon = emojiString
                    
                    Task { await authVM.updateUser(user) }
                }
            }
    }
}

#Preview {
    let user = User(name: "Natanael", email: "")
    HomeView(currentUser: user)
        .environmentObject(AuthViewModel())
        .environmentObject(HabitViewModel(service: MockHabitService(), currentUser: user))
        .environmentObject(FriendsViewModel(authService: MockAuthService(), friendsService: MockFriendsService(), currentUser: user))
        .preferredColorScheme(.dark)
}
