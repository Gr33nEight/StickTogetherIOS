//
//  CreateAccountView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var vm: AuthViewModel
    
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var rePasswordError: String?
    
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 20) {
                Spacer()
                Text("Welcome Back")
                    .font(.customAppFont(size: 34, weight: .bold))
                Text("Login to you account with\nEmail and Password")
                    .multilineTextAlignment(.center)
                    .font(.customAppFont(size: 13, weight: .regular))
                    .fixedSize()
            }
            Divider()
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
            Spacer()
            HStack {
                Text("Don't have account?")
                
                Button {
                    // go to register view
                } label: {
                    Text("Create New")
                        .underline()
                        .foregroundStyle(Color.custom.secondary)
                }
            }.font(.myCaption)
        }.foregroundStyle(Color.custom.text)
            .padding()
            .background(
                Color.custom.background.ignoresSafeArea()
            )
            .onChange(of: vm.email) { _, _ in
                emailError = validateEmail(vm.email)
            }
            .onChange(of: vm.password) { _, _ in
                passwordError = validatePassword(vm.password)
            }
    }
    private func validateEmail(_ email: String) -> String? {
            guard !email.isEmpty else { return nil }
            return email.contains("@") ? nil : "Invalid email address"
        }

        private func validatePassword(_ pw: String) -> String? {
            guard !pw.isEmpty else { return nil }
            return pw.count >= 6 ? nil : "Password must be at least 6 characters"
        }
}

#Preview {
    CreateAccountView(vm: AuthViewModel())
}
