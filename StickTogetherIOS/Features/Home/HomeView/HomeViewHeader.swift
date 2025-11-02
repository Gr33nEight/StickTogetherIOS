//
//  HomeViewHeader.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    var header: some View {
        HStack {
            Text("\(Date().timeOfDayGreeting),\n\(currentUser.name.capitalized) 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            Button {
                signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
        }.foregroundStyle(Color.custom.text)
            .padding([.top, .horizontal], 20)
    }
}
