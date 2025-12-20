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
    let done: Int
    let skipped: Int

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

    private var total: CGFloat { max(CGFloat(done + skipped), 1) }
    private var doneFraction: CGFloat { CGFloat(done) / total }
    private var skippedFraction: CGFloat { CGFloat(skipped) / total }
    private var isToday: Bool { Calendar.current.isDate(date, inSameDayAs: Date()) }
    private var fullyDone: Bool { done == 0 || skipped == 0}
    private var fullStateColor: Color {
        if done == 0 && skipped == 0 {
            return Color.custom.grey
        }else if done > 0 {
            return Color.custom.primary
        }else if skipped > 0 {
            return Color.custom.red
        }else{
            return Color.clear
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                if fullyDone {
                    if isToday {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.custom.text, lineWidth: 3)
                    }else{
                        RoundedRectangle(cornerRadius: 25)
                            .fill(fullStateColor)
                    }
                }else {
                    if isToday {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.custom.text, lineWidth: 3)
                    }else{
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.red, lineWidth: 3)
                        RoundedRectangle(cornerRadius: 25)
                            .trim(from: 0, to: doneFraction)
                            .stroke(Color.green, lineWidth: 3)
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
            }.foregroundColor(skipped == 0 && done == 0 ? Color(.systemGray) : Color.custom.text)
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
                    done: 1,
                    skipped: 0
                )
            }
        }.padding()
        .background(Color.custom.background)
        
    }
    .preferredColorScheme(.dark)
}
