//
//  HomeViewContent.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView {
    @ViewBuilder
    var content: some View {
        HStack {
            Text("Track your\nhabit")
                .font(.myTitle)
            Spacer()
            Button(action: {}, label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                    Image(systemName: "plus")
                }.frame(width: 50)
            })
        }.foregroundColor(.custom.text)
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                ForEach(0..<3) { i in
                    HabitCell(habit: Habit(icon: "🏃", title: "Go for a walk"))
                }
            }
        }
    }
}
