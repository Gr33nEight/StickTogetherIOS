//
//  CreateAccountView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var vm: AuthViewModel
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var rePassword: String = ""
    
    @State var nameError: String?
    @State var emailError: String?
    @State var passwordError: String?
    @State var rePasswordError: String?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            header
            Divider()
            content
            Spacer()
            footer
        }.foregroundStyle(Color.custom.text)
            .padding()
            .background(
                Color.custom.background.ignoresSafeArea()
            )
            .onChange(of: email) { _, _ in
                emailError = validateEmail(email)
            }
            .onChange(of: password) { _, _ in
                passwordError = validatePassword(password)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
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
