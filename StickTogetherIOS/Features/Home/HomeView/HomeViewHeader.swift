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
            //TODO: Handle that optional later
            Text("Good Morning,\n\(currentUser.name.capitalized) 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            Button {
                signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
        }.foregroundStyle(Color.custom.text)
            .padding([.top, .leading, .trailing], 20)
    }
}
