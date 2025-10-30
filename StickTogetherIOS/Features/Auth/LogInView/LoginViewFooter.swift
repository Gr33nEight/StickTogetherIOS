//
//  LoginViewFooter.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

extension LogInView {
    var footer: some View {
        HStack {
            Text("Don't have account?")
            
            NavigationLink {
                CreateAccountView(vm: vm)
            } label: {
                Text("Create New")
                    .underline()
                    .foregroundStyle(Color.custom.secondary)
            }

//            Button {
//                // go to register view
//            } label: {
//                Text("Create New")
//                    .underline()
//                    .foregroundStyle(Color.custom.secondary)
//            }
        }.font(.myCaption)
    }
}


