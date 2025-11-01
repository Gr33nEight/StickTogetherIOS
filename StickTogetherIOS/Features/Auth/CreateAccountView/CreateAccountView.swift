//
//  CreateAccountView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var vm: AuthViewModel
    
    @State var nameError: String?
    @State var emailError: String?
    @State var passwordError: String?
    @State var rePasswordError: String?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 38) {
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
            .onChange(of: vm.email) { _, _ in
                emailError = validateEmail(vm.email)
            }
            .onChange(of: vm.password) { _, _ in
                passwordError = validatePassword(vm.password)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                vm.resetState()
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
    CreateAccountView(vm: AuthViewModel()).preferredColorScheme(.dark)
}
