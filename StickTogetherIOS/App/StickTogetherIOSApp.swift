//
//  StickTogetherIOSApp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

@main
struct StickTogetherIOSApp: App {
    @StateObject var diContainer = DIContainer()
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(diContainer)
                .preferredColorScheme(.dark)
        }
    }
}
