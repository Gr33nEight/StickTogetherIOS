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
    
    let authenticatedAppContainer: AuthenticatedAppContainer
    
    var body: some View {
        NavigationStack(path: $path) {
            RootView(selected: $selected, container: authenticatedAppContainer)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .habit(let container): HabitView(habit: container.habit, selectedDate: container.selectedDate, friends: container.friends)
                    case .createHabit: CreateHabitView()
                    case .notifications: NotificationView()
                    }
                }
        }.rootRouter(path: $path)
    }
}
