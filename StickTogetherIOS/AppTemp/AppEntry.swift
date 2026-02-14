//
//  AppEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct AppEntryTemp: View {
    @StateObject private var viewModel: SessionViewModel
    var body: some View {
        Group {
            // if auth
            if let user = {
                NavigationStackContentView(container: AuthenticatedAppContainer(userId: <#T##String#>))
            } else {
//                LogInView()
            }
        }
    }
}
