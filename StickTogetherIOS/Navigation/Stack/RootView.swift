//
//  RootView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct RootView: View {
    @Binding var selected: TabDestinations
    let container: AuthenticatedAppContainer
    
    var body: some View {
        NavigationContainer(selected: $selected)
    }
}
