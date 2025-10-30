//
//  HomeViewCalendar.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension HomeView  {
    var calendar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<8) { i in
                   DayCell(dayOfWeek: "Mon", dayOfMonth: 20+i)
                }
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}
