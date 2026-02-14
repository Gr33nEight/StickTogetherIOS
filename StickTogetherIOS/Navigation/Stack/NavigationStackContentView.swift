//
//  NavigationStackContentView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 05/12/2025.
//

import SwiftUI

struct NavigationStackContentView: View {
    @State private var path = [Route]()
    @State private var selected: TabDestinations = .home
    
    let container: AuthenticatedAppContainer
    
    var body: some View {
        NavigationStack(path: $path) {
            RootView(selected: $selected, container: container)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .habit(let container): container.makeHabitView()
                    case .createHabit: container.makeCreateHabitView()
                    case .notifications: container.makeNotificationView()
                    }
                }
        }.rootRouter(path: $path)
    }
}
