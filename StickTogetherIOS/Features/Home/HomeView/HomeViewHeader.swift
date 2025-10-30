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
            Text("Good Morning, Natanael 👋")
                .font(.customAppFont(size: 28, weight: .bold))
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "bell")
            }
        }.foregroundStyle(Color.custom.text)
            .padding([.top, .leading, .trailing], 20)
    }
}
