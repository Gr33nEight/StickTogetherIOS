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
                text: $vm.name,
                placeholder: "Name",
                systemIcon: "person",
                isSecure: false,
                errorMessage: nameError
            )
            CustomTextField(
                text: $vm.email,
                placeholder: "Email",
                systemIcon: "envelope",
                isSecure: false,
                errorMessage: emailError
            )
            CustomTextField(
                text: $vm.password,
                placeholder: "New Password",
                systemIcon: "lock",
                isSecure: true,
                errorMessage: passwordError
            )
            CustomTextField(
                text: $vm.rePassword,
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
                           vm.password.isEmpty == false &&
                           vm.email.isEmpty == false &&
                           vm.name.isEmpty == false &&
                           vm.rePassword.isEmpty == false)
        
        Button(action: {
            if hasNoErrors {
                Task { await vm.signUp() }
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
