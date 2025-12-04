//
//  AppEntry.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 29/10/2025.
//

import SwiftUI

struct AppEntry: View {
    @ObservedObject var di: DIContainer
    var body: some View {
        ZStack {
            AppCoordinatorView(di: di)
            LoadingOverlay()
        }.task {
            await CalendarManager.shared.requestAccess()
            NotificationManager.shared.requestAuthorization { granted in
                print("Notification allowed:", granted)
            }
        }
    }
}
