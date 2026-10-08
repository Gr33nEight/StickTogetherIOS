//
//  CreateAccountContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import AuthenticationServices

extension CreateAccountView {
    @ViewBuilder
    var content: some View {
        textFields
        createAccountButton
        socialMediaButtons
    }
    
    var textFields: some View {
        VStack(spacing: 15) {
            CustomTextField(
                text: $name,
                placeholder: "Name",
                icon: .user,
                isSecure: false,
                errorMessage: nameError
            )
            CustomTextField(
                text: $email,
                placeholder: "Email",
                icon: .mail,
                isSecure: false,
                errorMessage: emailError
            )
            CustomTextField(
                text: $password,
                placeholder: "New Password",
                icon: .lock,
                isSecure: true,
                errorMessage: passwordError
            )
            CustomTextField(
                text: $rePassword,
                placeholder: "Confirm Password",
                icon: .lock,
                isSecure: true,
                errorMessage: rePasswordError
            )
        }
    }
    
    @ViewBuilder
    var createAccountButton: some View {
        let hasNoErrors = (passwordError == nil &&
                           emailError == nil &&
                           nameError == nil &&
                           rePasswordError == nil &&
                           password.isEmpty == false &&
                           email.isEmpty == false &&
                           name.isEmpty == false &&
                           rePassword.isEmpty == false)
        
        Button(action: {
            if hasNoErrors {
                Task { await vm.signUp(email: email, password: password, name: name) }
            }
        }, label: {
            Text("Create Account")
        }).customButtonStyle(hasNoErrors ? .primary : .disabled)
    }
    
    @ViewBuilder
    var socialMediaButtons: some View {
        HStack(spacing: 15) {
            VStack { Divider() }
            Text("Or")
                .font(.myCaption)
            VStack { Divider() }
        }
        VStack {
            SignInWithAppleButton(.signUp) { request in
                vm.prepareAppleSignInRequest(request)
            } onCompletion: { result in
                Task {
                    await vm.handleAppleSignInResult(result)
                }
            }.signInWithAppleButtonStyle(.black)
                .frame(height: 44)
            GoogleSignInButton(title: "Sign up with Google", style: .filled) {
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
