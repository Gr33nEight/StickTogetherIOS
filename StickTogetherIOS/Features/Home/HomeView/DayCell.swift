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
    let state: HabitState

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
        ZStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(state.color)
                ZStack {
                    if isToday {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.white)
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(lineWidth: 1.5)
                            .fill(state.color.opacity(0.4))
                    }
                }
            }.frame(width: 35, height: isSelected ? 60 : 35)
            VStack(spacing: 0) {
                Text(dayNumber)
                    .font(.customAppFont(size: 15, weight: .bold))
                    .padding(.vertical, 8)
                Text(dayName)
                    .font(.customAppFont(size: 11, weight: .medium))
                    .fixedSize()
                    .padding(.top, 5)
            }.foregroundColor(state.textColor)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TabView {
        HStack(spacing: 10) {
            ForEach(20..<26) { date in
                DayCell(
                    date: Date().addingTimeInterval(24 * 60 * 60 * Double(date - 23)),
                    isSelected: date == 23,
                    state: (date < 24 ? (date % 2 == 1 ? .done : .skipped) : .none)
                )
            }
        }.padding()
        .background(Color.custom.background)
        
    }
    .preferredColorScheme(.dark)
}
