//
//  CreateAccountHeader.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateAccountView {
    var header: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Welcome Back")
                .font(.customAppFont(size: 34, weight: .bold))
            Text("Login to you account with\nEmail and Password")
                .multilineTextAlignment(.center)
                .font(.customAppFont(size: 13, weight: .regular))
                .fixedSize()
        }
    }
}
