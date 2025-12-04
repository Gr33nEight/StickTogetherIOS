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
            Text("\(Date().timeOfDayGreeting),\n\(profileVM.safeUser.name.capitalized) 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            NavigationLink {
                NotificationView()
            } label: {
                Image(.bell)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }.overlay {
                Image(systemName: "\(appNotificationsVM.appNotifications.count)")
                    .foregroundColor(Color.custom.red)
                    .symbolVariant(.fill)
                    .symbolVariant(.circle)
                    .allowsHitTesting(false)
                    .offset(x: 10, y: -10)
            }

        }.foregroundStyle(Color.custom.text)
            .padding([.top, .horizontal], 20)
    }
}

//#Preview {
//    let user = User(name: "Natanael", email: "")
//    HomeView()
//        .environmentObject(AuthViewModel())
//        .environmentObject(HabitViewModel(service: MockHabitService(), currentUser: user))
//        .environmentObject(FriendsViewModel(profileService: FirebaseProfileService(), friendsService: FirebaseFriendsService(), currentUser: user))
//        .environmentObject(ProfileViewModel(profileService: FirebaseProfileService()))
//        .preferredColorScheme(.dark)
//}
