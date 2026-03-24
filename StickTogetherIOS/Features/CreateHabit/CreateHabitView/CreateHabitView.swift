//
//  CreateHabitView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 30/10/2025.
//

import SwiftUI
import ElegantEmojiPicker

struct CreateHabitView: View {
    @StateObject var viewModel: CreateHabitViewModel
    @StateObject var friendsListVM: FriendsListViewModel
    
    @State var addToCalendar = false
    @State var showFriendsList = false
    @Namespace var frequencyAnimation
    
    @Environment(\.showToastMessage) var showToastMessage
    @Environment(\.dismiss) var dismiss

    @State var isEmojiPickerPresented = false

    var body: some View {
        GeometryReader { _ in
            CustomView(title: "Create Habit") {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        titleTextField
                        frequencySelection
                        inviteFriend
                        reminder
                        addToCalendarView
                    }.padding(.vertical)
                    .font(.myBody)
                    .foregroundStyle(Color.custom.text)
                }
                .padding(.horizontal)
            } buttons: {
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Go back")
                    }.customButtonStyle(.secondary)

                    Button {
                        Task {
                            await viewModel.createHabit()
                        }
                    } label: {
                        Text("Create")
                    }.customButtonStyle(.primary)
                }
            } icons: {}
            .ignoresSafeArea(.keyboard)
        }.emojiPicker(isPresented: $isEmojiPickerPresented, selectedEmoji: $viewModel.selectedEmoji)
            .fullScreenCover(isPresented: $showFriendsList, content: {
                FriendsListView(
                    viewModel: friendsListVM,
                    onAddBuddy: { usr in
                        viewModel.buddy = usr
                    })
                    .modal()
            })
            .onChange(of: viewModel.event) { _, event in
                guard let event else { return }
                switch event {
                case .success:
                    dismiss()
                case .error(let error):
                    showToastMessage(.failed(error))
                }
            }
    }
}
