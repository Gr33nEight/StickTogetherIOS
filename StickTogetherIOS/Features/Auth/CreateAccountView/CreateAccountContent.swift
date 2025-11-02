//
//  CreateAccountContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

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
                systemIcon: "person",
                isSecure: false,
                errorMessage: nameError
            )
            CustomTextField(
                text: $email,
                placeholder: "Email",
                systemIcon: "envelope",
                isSecure: false,
                errorMessage: emailError
            )
            CustomTextField(
                text: $password,
                placeholder: "New Password",
                systemIcon: "lock",
                isSecure: true,
                errorMessage: passwordError
            )
            CustomTextField(
                text: $rePassword,
                placeholder: "Confirm Password",
                systemIcon: "lock",
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
