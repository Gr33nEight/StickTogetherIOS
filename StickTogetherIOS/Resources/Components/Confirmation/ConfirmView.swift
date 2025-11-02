//
//  ConfirmView.swift
//  QueensGame
//
//  Created by Natanael Jop on 17/07/2025.
//
import SwiftUI

struct ConfirmView: View {
    let confirmation: Confirmation
    let dismiss: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Text(confirmation.question)
                .multilineTextAlignment(.center)
                .font(.mySubtitle)
                .foregroundStyle(Color.custom.text)
            HStack(spacing: 24) {
                Button(action: {
                    dismiss()
                    confirmation.yesAction()
                }, label: {
                    Text("Yes")
                }).customButtonStyle(.secondary)
                Button(action: {
                    dismiss()
                    confirmation.noAction()
                }, label: {
                    Text("No")
                }).customButtonStyle(.primary)
            }
        }.padding(24)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).stroke(Color.custom.primary, lineWidth: 5)
                RoundedRectangle(cornerRadius: 20).fill(Color.custom.background)
            }
        ).padding(24)
    }
}
