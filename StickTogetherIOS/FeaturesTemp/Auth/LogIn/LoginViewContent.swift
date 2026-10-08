//
//  LoginViewBody.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import AuthenticationServices
import UIKit

extension LogInView {
    @ViewBuilder
    var content: some View {
        let hasNoErrors = (passwordError == nil && emailError == nil && email.isEmpty == false && password.isEmpty == false)
        
        VStack(spacing: 15) {
            CustomTextField(
                text: $email,
                placeholder: "Email",
                icon: .mail,
                isSecure: false,
                errorMessage: emailError
            )

            CustomTextField(
                text: $password,
                placeholder: "Password",
                icon: .lock,
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
            if hasNoErrors {
                UIApplication.shared.endEditing()
                Task { await vm.signIn(email: email, password: password) }
            }
        }, label: {
            Text("Login")
        }).customButtonStyle(hasNoErrors ? .primary : .disabled)
        HStack(spacing: 15) {
            VStack { Divider() }
            Text("Or")
                .font(.myCaption)
            VStack { Divider() }
        }
        VStack {
            SignInWithAppleButton(.signIn) { request in
                vm.prepareAppleSignInRequest(request)
            } onCompletion: { result in
                Task {
                    await vm.handleAppleSignInResult(result)
                }
            }.signInWithAppleButtonStyle(.black)
                .frame(height: 44)
            GoogleSignInButton(style: .filled) {
                Task {
                    guard let viewController = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap(\.windows)
                        .first(where: \.isKeyWindow)?.rootViewController else { return }
                    await vm.handleGoogleSignInResult(presenting: viewController)
                }
            }
        }
    }
}
