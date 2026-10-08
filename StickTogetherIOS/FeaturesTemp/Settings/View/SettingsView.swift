//
//  SettingsView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.confirm) var confirm

    // local preference state (these could be backed by AppStorage or your user model)
    @State private var language: String = "English"
    @State private var notificationsEnabled: Bool = true
    @State private var theme: String = "Default"
    @State private var mainHabitType: String = HabitType.allCases.map({ $0.text }).first ?? ""

    // Build array of items (heterogeneous)
    private var preferences: [SettingsPreferenceItem] {
        [
            .picker(icon: "globe", text: "Language", options: Language.allCases.map({$0.rawValue}), selection: $language),
            .toggle(icon: "bell", text: "Notifications", value: $notificationsEnabled),
            .picker(icon: "paintpalette", text: "Theme", options: Theme.allCases.map({$0.rawValue.capitalized}), selection: $theme),
            //.picker(icon: "checklist", text: "Main Habit Type", options: HabitType.allCases.map({ $0.text }), selection: $mainHabitType)
        ]
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    confirm(question: "Are you sure you want to sign out?") {
                        viewModel.signOutUser()
                    }
                } label: {
                    Text("Logout")
                        .foregroundStyle(Color.custom.red)
                }
            }
            if let user = viewModel.currentUser {
                ScrollView {
                    VStack(spacing: 15) {
                        VStack(spacing: 8){
                            ZStack {
                                Text(user.icon)
                                    .font(.system(size: 35))
                                    .shadow(color: .black.opacity(0.5), radius: 5)
                            }.padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.custom.text)
                                )
                            Text(user.name)
                                .foregroundStyle(Color.custom.text)
                                .font(.mySubtitle)
                            Text(user.email)
                                .foregroundStyle(Color(.systemGray))
                                .font(.customAppFont(size: 15))
                        }

                        Button {
                            // Edit Profile
                        } label: {
                            HStack {
                                Text("Edit profile").font(.customAppFont(size: 15))
                                Image(systemName: "chevron.right")
                                    .font(.customAppFont(size: 13, weight: .semibold))
                            }.padding(10)
                                .padding(.horizontal, 10)
                                .foregroundStyle(Color.custom.text)
                                .background(Capsule().fill(Color.accent))
                        }

                        VStack(alignment: .leading, spacing: 25) {
    //                        Text("Preferences")
    //                            .foregroundStyle(Color.custom.text.opacity(0.5))
    //                            .font(.customAppFont(size: 15, weight: .regular))
                            ForEach(preferences) { pref in
                                SettingsCellView(item: pref)
                            }
                        }.padding(.top)
                            .padding(.horizontal, 5)
                    }
                }
            }

            Spacer()
        }.padding()
            .padding(.bottom, 100)
            .background(Color.custom.background)
            .task {
                viewModel.startListeningToCurrentUser()
            }
    }
}
