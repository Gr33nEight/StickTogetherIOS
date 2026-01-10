//
//  LoadingOverlay.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//


import SwiftUI

struct LoadingOverlay: View {
    @EnvironmentObject var loading: LoadingManager

    var body: some View {
        ZStack {
            if loading.isLoading {
                LoadingView()
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: loading.isLoading)
        .allowsHitTesting(loading.isLoading)
        .accessibility(hidden: !loading.isLoading)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Blur(style: .prominent)
            ProgressView().tint(.accent)
        }.ignoresSafeArea()
    }
}

//#Preview {
//    FriendsListView()
//        .environmentObject(FriendsViewModel(profileService: MockProfileService(), friendsService: MockFriendsService(), currentUser: User(name: "", email: "")))
//        .overlay {
//            LoadingOverlay().environmentObject(LoadingManager())
//        }
//        .preferredColorScheme(.dark)
//}
