//
//  CreateAccountFooter.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateAccountView {
    var footer: some View {
        HStack {
            Text("Alread have account?")
            
            Button {
                dismiss()
                // go to back to login view
            } label: {
                Text("Login Now")
                    .underline()
                    .foregroundStyle(Color.custom.secondary)
            }
        }.font(.myCaption)
    }
}
