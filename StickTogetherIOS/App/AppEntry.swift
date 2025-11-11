//
//  AppEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct AppEntry: View {
    var body: some View {
        ZStack {
            AppCoordinatorView()
            LoadingOverlay()
        }.task {
            await CalendarManager.shared.requestAccess()
            NotificationManager.shared.requestAuthorization { granted in
                print("Notification allowed:", granted)
            }
        }
    }
}
