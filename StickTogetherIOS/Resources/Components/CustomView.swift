//
//  CustomView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CustomView<Content: View, Buttons: View, Icons: View>: View {
    let title: String
    var dismissIcon: String = "chevron.left"
    @ViewBuilder var content: Content
    @ViewBuilder var buttons: Buttons
    @ViewBuilder var icons: Icons
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }, label: {
                    Image(systemName: dismissIcon)
                        .bold()
                })
                Spacer()
                icons
            }.padding(.horizontal)
                .padding(.vertical, 8)
            .overlay {
                Text(title)
                    .font(.mySubtitle)
                    .foregroundStyle(Color.custom.text)
            }
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.darkGrey.opacity(0.33))
                )
            buttons.padding([.horizontal, .top])
        }.background(Color.custom.background.ignoresSafeArea())
            .navigationBarBackButtonHidden()
    }
}
