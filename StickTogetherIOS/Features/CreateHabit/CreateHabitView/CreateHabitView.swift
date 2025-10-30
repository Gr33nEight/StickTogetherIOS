//
//  CreateHabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI

struct CreateHabitView: View {
    @State var title = ""
    @State var pickedFrequency: Frequency = .daily
    @State var dayStepper = 1
    @State var date = Date()
    @State var setReminder = false
    @State var alone = false
    @Namespace var frequencyAnimation
    @Environment(\.dismiss) var dismiss
    var body: some View {
        CustomView(title: "Create Habit") {
            ScrollView {
                VStack(spacing: 20) {
                    titleTextField
                    frequencySelection
                    reminder
                    inviteFriend
                }.font(.myBody)
                    .foregroundStyle(Color.custom.text)
            }.padding()
        } buttons: {
            HStack(spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Text("Go back")
                }.customButtonStyle(.secondary)
                Button {
                    // create
                } label: {
                    Text("Create")
                }.customButtonStyle(.primary)
            }
        } icons: {}
    }
}

#Preview {
    CreateHabitView().preferredColorScheme(.dark)
}
