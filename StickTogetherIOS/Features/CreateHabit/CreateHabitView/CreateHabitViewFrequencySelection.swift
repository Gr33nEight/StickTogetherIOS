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
                ForEach(Frequency.allCases, id:\.self) { f in
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
            Stepper("Every \(dayStepper) day", value: $dayStepper, in: 1...7)
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
            DatePicker("Start date", selection: $date, displayedComponents: .date)
                .padding(10)
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.custom.lightGrey)
                )
        }.customCellViewModifier()
    }
}
