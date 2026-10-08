//
//  NavigationContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct NavigationContainer: View {
    @Binding var selected: TabDestinations
    let container: AuthenticatedAppContainer
        
    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                NavigationBarView(selected: $selected)
                    .padding(.horizontal)
            }
        }.task {
            
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch selected {
        case .home:
            container.makeHomeView()
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
            container.makeFriendsView()
//            FriendsListView(fullList: true)
        case .settings:
            container.makeSettingsView()
        }
    }
}
