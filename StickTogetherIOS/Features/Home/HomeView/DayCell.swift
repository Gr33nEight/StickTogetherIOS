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
    let wasDone: Bool

    private var dayName: String {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df.string(from: date)
    }

    private var dayNumber: String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }

    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        ZStack {
            isToday ? Color.custom.primary : wasDone ? Color.custom.secondary : Color.custom.lightGrey
            VStack(spacing: 6) {
                Text(dayNumber)
                    .font(.customAppFont(size: 20, weight: .bold))
                Text(dayName)
                    .font(.customAppFont(size: 12, weight: .medium))
                    .fixedSize()
            }.foregroundColor(isToday ? Color.custom.text : wasDone ? Color.custom.grey : Color(.systemGray))
        }.frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .scaleEffect(isSelected ? 0.92 : 1)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: isSelected ? 2 : 0)
                .fill(Color.custom.secondary)
                .scaleEffect(!isSelected ? 0 : 1.1)
        )
    }
}


#Preview {
    TabView {
        HStack(spacing: 15) {
            ForEach(20..<26) { date in
                DayCell(date: Date().addingTimeInterval(24 * 60 * 60 * Double(date - 23)), isSelected: date == 24, wasDone: (date < 24 && date % 2 == 0))
            }
        }.padding()
        .background(Color.custom.background)
        
    }
    .preferredColorScheme(.dark)
}
