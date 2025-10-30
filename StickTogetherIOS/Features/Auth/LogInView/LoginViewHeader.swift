//
//  LoginViewHeader.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

extension LogInView {
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
