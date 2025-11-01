//
//  StickTogetherIOSApp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct StickTogetherIOSApp: App {
    @StateObject var diContainer = DIContainer()
    @StateObject var loading = LoadingManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntry()
                .customToastMessage()
                .environmentObject(diContainer)
                .environmentObject(loading)
                .preferredColorScheme(.dark)
        }
    }
}
