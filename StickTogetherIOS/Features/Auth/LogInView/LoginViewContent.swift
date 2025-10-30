//
//  LoginViewBody.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

extension LogInView {
    var body: some View {
        VStack(spacing: 15) {
            CustomTextField(
                text: $vm.email,
                placeholder: "Email",
                systemIcon: "envelope",
                isSecure: false,
                errorMessage: emailError
            )

            CustomTextField(
                text: $vm.password,
                placeholder: "Password",
                systemIcon: "lock",
                isSecure: true,
                errorMessage: passwordError
            )
            Button {
                // go to forgot password
            } label: {
                Text("Forgot password?")
                    .underline()
                    .foregroundStyle(Color.custom.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.myCaption)
            }
        }
        Button(action: {
//                vm.login()
        }, label: {
            Text("Login")
        }).customButtonStyle(.primary)
        HStack(spacing: 15) {
            VStack { Divider() }
            Text("Or")
                .font(.myCaption)
            VStack { Divider() }
        }
        HStack(spacing: 30) {
            Button(action: {}, label: {
                Image(.google)
            })
            Button(action: {}, label: {
                Image(.apple)
            })
            Button(action: {}, label: {
                Image(.facebook)
            })
        }
    }
}
