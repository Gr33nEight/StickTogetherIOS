//
//  NavigationBarView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 15/11/2025.
//

import SwiftUI

struct NavigationBarView: View {
    @EnvironmentObject var appNotifications: AppNotificationsViewModel
    @EnvironmentObject var friendsVM: FriendsViewModel
    @Environment(\.navigate) var navigate
    @Binding var selected: NavigationDestinations
    @State private var selectedWithAnim = NavigationDestinations.home
    
    @Namespace private var navNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationDestinations.allCases, id: \.rawValue) { dest in
                let isPicked = self.selectedWithAnim == dest
                let isHomeAndPicked = self.selectedWithAnim == .home && dest == .home
                
                Button {
                    if isHomeAndPicked {
                        navigate(.push(.createHabit))
                    }else{
                        selected = dest
                    }
                } label: {
                    navigationElement(dest: dest, isPicked: isPicked, isHomeAndPicked: isHomeAndPicked)
                }
            }
        }.frame(maxWidth: .infinity)
            .padding(12)
            .background(
                Capsule()
                    .fill(Color.custom.darkGrey)
            )
            .onChange(of: selected) { _, s in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedWithAnim = s
                }
            }
    }
    @ViewBuilder
    func navigationElement(dest: NavigationDestinations, isPicked: Bool, isHomeAndPicked: Bool) -> some View {
        HStack {
            ZStack {
                if isHomeAndPicked {
                    Image(systemName: "plus")
                }else{
                    Image(dest.icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .customBadge(number: dest == .friends ? appNotifications.friendsRequestNotReadNotificationsNum : 0)
                }
            }.matchedGeometryEffect(id: "icon_\(dest.rawValue)", in: navNamespace)
                .frame(height: 24)
            if isPicked {
                Spacer()
                Text(dest.rawValue.capitalized)
                    .font(.customAppFont(size: 15, weight: .semibold))
                    .matchedGeometryEffect(id: "label_\(dest.rawValue)", in: navNamespace)
                Spacer()
            }
        }
        .foregroundStyle(isPicked ? Color.custom.secondary : Color.custom.text)
        .frame(maxWidth: isPicked ? .infinity : 50)
        .padding(isPicked ? 12 : 0)
        .background(
            Group {
                if isPicked {
                    Capsule()
                        .fill(Color.custom.background)
                        .matchedGeometryEffect(id: "nav_bg", in: navNamespace)
                } else {
                    Color.clear
                }
            }
        )
    }
}
