//
//  NavigationContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct NavigationContainer: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var loading: LoadingManager
    
    @Binding var selected: NavigationDestinations
        
    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                NavigationBarView(selected: $selected)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch selected {
        case .home:
            HomeView()
//        case .stats:
//            StatsView()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.custom.background)
//            
//        case .chats:
//            ChatsView()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.custom.background)
        case .friends:
            FriendsListView(fullList: true)
        case .settings:
            SettingsView()
        }
    }
}
