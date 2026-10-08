//
//  GoogleButtonStyle.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 11/11/2025.
//


import SwiftUI

enum GoogleButtonStyle {
    case filled   // dark, similar weight to "Sign in with Apple" filled
    case outline  // white with border and logo area (classic Google button)
}

struct GoogleSignInButton: View {
    let title: String
    let style: GoogleButtonStyle
    let action: () -> Void

    init(title: String = "Sign in with Google",
         style: GoogleButtonStyle = .outline,
         action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 12) {
                logoView
                    .frame(width: 12)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }.frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(RoundedRectangle(cornerRadius: 1, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .background(background)
        .overlay(border)
        .cornerRadius(10)
//        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
        .accessibilityLabel(title)
    }

    // MARK: - Subviews / styling

    @ViewBuilder
    private var logoView: some View {
        Image(.google)
            .resizable()
            .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .filled:
            Color(.black) // dark / black (will adapt to light/dark)
        case .outline:
            Color(.systemBackground)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch style {
        case .filled:
            EmptyView()
        case .outline:
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 1)
        }
    }

    private var googleGradient: LinearGradient {
        // lightweight approximation of Google G colors
        LinearGradient(
            colors: [
                Color(red: 66/255, green: 133/255, blue: 244/255), // blue
                Color(red: 219/255, green: 68/255, blue: 55/255),  // red
                Color(red: 244/255, green: 180/255, blue: 0/255),  // yellow
                Color(red: 15/255, green: 157/255, blue: 88/255)   // green
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // shadow / appearance tuned to match Apple button weight
    private var shadowColor: Color {
        switch style {
        case .filled: return Color.black.opacity(0.25)
        case .outline: return Color.black.opacity(0.08)
        }
    }
    private var shadowRadius: CGFloat { style == .filled ? 6 : 2 }
    private var shadowYOffset: CGFloat { style == .filled ? 3 : 1 }
}

// MARK: - Preview / example usage

struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            GoogleSignInButton(title: "Sign in with Google", style: .filled) {
                print("google filled tapped")
            }

            GoogleSignInButton(title: "Sign in with Google", style: .outline) {
                print("google outline tapped")
            }
        }
        .padding()
        .background(Color.custom.background)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
