//
//  CustomTextField.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: ImageResource?
    let isSecure: Bool
    let errorMessage: String?

    @FocusState private var isFocused: Bool
    
    @State private var showPassword: Bool = false

    private var state: TextFieldState {
        if let err = errorMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
           !err.isEmpty {
            return .error(err)
        }
        if text.isEmpty {
            return isFocused ? .focused : .notFilled
        } else {
            return .filled
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(state.borderColor, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 10).fill(state.backgroundColor))

                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(state.textColor)
                    }

                    if isSecure && !showPassword {
                        SecureField("", text: $text)
                            .focused($isFocused)
                            .font(.myBody)
                            .foregroundStyle(Color.custom.text)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                            .font(.myBody)
                            .foregroundStyle(Color.custom.text)
                    }

                    Spacer()
                    if isSecure {
                        Image(showPassword ? .eye : .hide)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .onTapGesture {
                                showPassword.toggle()
                            }
                            .foregroundColor(state.textColor)
                    }
                    
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)

                if text.isEmpty {
                    HStack {
                        if icon != nil {
                            Spacer().frame(width: 22 + 12)
                        }
                        Text(placeholder)
                            .font(.myBody)
                            .foregroundStyle(state == .focused ? .custom.grey : state.textColor)
                        Spacer()
                    }.onTapGesture {
                        isFocused = true
                    }
                    .padding(.horizontal, 18)
                }
            }
            .accentColor(.custom.primary)
            .animation(.easeInOut(duration: 0.12), value: state)
            .frame(height: 48)

            if case .error(let msg) = state {
                HStack {
                    Text(msg)
                        .font(.customAppFont(size: 12, weight: .regular))
                        .foregroundColor(.custom.red)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut, value: state)
            }
        }
    }
}
