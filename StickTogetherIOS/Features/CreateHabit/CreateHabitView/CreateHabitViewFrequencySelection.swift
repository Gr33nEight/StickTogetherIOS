//
//  CreateHabitViewFrequencySelection.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

extension CreateHabitView {
    var frequencySelection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 0) {
                ForEach(FrequencyType.allCases, id:\.self) { f in
                    Button {
                        pickedFrequency = f
                    } label: {
                        ZStack {
                            if pickedFrequency == f {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.custom.primary)
                                    .matchedGeometryEffect(id: "freq-bg", in: frequencyAnimation)
                            }
                            
                            Text(f.rawValue)
                                .font(.myBody)
                                .foregroundColor(pickedFrequency == f ? Color.custom.text : Color(.systemGray))
                                .frame(width: (UIScreen.main.bounds.size.width-60)/4, height: 45)
                        }
                    }
                }
            }.animation(.bouncy, value: pickedFrequency)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            Stepper("Every \(interval == 1 ? pickedFrequency.value.dropLast() : ("\(interval) \(pickedFrequency.value)"))", value: $interval, in: 1...(pickedFrequency.limit))
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            if pickedFrequency == .weekly {
                HStack(spacing: 10) {
                    ForEach(Weekday.allCases, id:\.self) { day in
                        Button {
                            if let idx = pickedDays.firstIndex(where: { $0 == day }) {
                                pickedDays.remove(at: idx)
                            }else{
                                pickedDays.append(day)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(pickedDays.contains(day) ? Color.custom.primary : Color.custom.lightGrey)
                                Text(day.shortened)
                                    .font(.customAppFont(size: 12, weight: .medium))
                                    .foregroundStyle(pickedDays.contains(day) ? Color.custom.text : Color(.systemGray))
                            }.frame(width: 38, height: 38)
                        }
                    }
                }
            }
            DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
        }.customCellViewModifier()
    }
}
