//
//  LoginViewBody.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import AuthenticationServices

extension LogInView {
    @ViewBuilder
    var content: some View {
        let hasNoErrors = (passwordError == nil && emailError == nil && email.isEmpty == false && password.isEmpty == false)
        
        VStack(spacing: 15) {
            CustomTextField(
                text: $email,
                placeholder: "Email",
                systemIcon: "envelope",
                isSecure: false,
                errorMessage: emailError
            )

            CustomTextField(
                text: $password,
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
                let nonce = Constants.randomNonceString()
                vm.currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = Constants.sha256(nonce)
            } onCompletion: { result in
                Task {
                    await vm.handleAppleSignInResult(result)
                }
            }.signInWithAppleButtonStyle(.black)
                .frame(height: 44)
            GoogleSignInButton(style: .filled) {
                Task {
                    await vm.handleGoogleSignInResult()
                }
            }
        }
    }
}
