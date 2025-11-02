//
//  DayCell.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool

    private var dayName: String {
        let df = DateFormatter()
        df.dateFormat = "E" // short weekday
        return df.string(from: date)
    }

    private var dayNumber: String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayName)
                .font(.customAppFont(size: 12, weight: .medium))
                .fixedSize()
            Text(dayNumber)
                .font(.customAppFont(size: 16, weight: .bold))
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.custom.primary : Color.custom.lightGrey)
                .clipShape(Circle())
                .foregroundColor(isSelected ? Color.custom.text : Color(.systemGray))
        }
        .padding(6)
    }
}
