//
//  LogInView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var vm: AuthViewModel

    @State var email: String = ""
    @State var password: String = ""
    
    @State var emailError: String?
    @State var passwordError: String?
    
    var body: some View {
        VStack(spacing: 50) {
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
