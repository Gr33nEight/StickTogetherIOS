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
                        viewModel.pickedFrequency = f
                    } label: {
                        ZStack {
                            if viewModel.pickedFrequency == f {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.custom.primary)
                                    .matchedGeometryEffect(id: "freq-bg", in: frequencyAnimation)
                            }
                            
                            Text(f.rawValue)
                                .font(.myBody)
                                .foregroundColor(viewModel.pickedFrequency == f ? Color.custom.text : Color(.systemGray))
                                .frame(width: (UIScreen.main.bounds.size.width-60)/4, height: 45)
                        }
                    }
                }
            }.animation(.bouncy, value: viewModel.pickedFrequency)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            Stepper("Every \(viewModel.interval == 1 ? viewModel.pickedFrequency.value.dropLast() : ("\(viewModel.interval) \(viewModel.pickedFrequency.value)"))", value: $viewModel.interval, in: 1...(viewModel.pickedFrequency.limit))
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            if viewModel.pickedFrequency == .weekly {
                HStack(spacing: 10) {
                    ForEach(Weekday.allCases, id:\.self) { day in
                        Button {
                            if let idx = viewModel.pickedDays.firstIndex(where: { $0 == day }) {
                                viewModel.pickedDays.remove(at: idx)
                            }else{
                                viewModel.pickedDays.append(day)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(viewModel.pickedDays.contains(day) ? Color.custom.primary : Color.custom.lightGrey)
                                Text(day.shortened)
                                    .font(.customAppFont(size: 12, weight: .medium))
                                    .foregroundStyle(viewModel.pickedDays.contains(day) ? Color.custom.text : Color(.systemGray))
                            }.frame(width: 38, height: 38)
                        }
                    }
                }
            }
            DatePicker("Start date", selection: $viewModel.startDate, displayedComponents: .date)
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            DatePicker("End date", selection: $viewModel.endDate, displayedComponents: .date)
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
        }.customCellViewModifier()
    }
}
