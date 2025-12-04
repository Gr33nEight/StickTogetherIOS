//
//  SettingsView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.confirm) var confirm
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    // The current user - if you want live updates pass Binding<User> instead

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
            .picker(icon: "checklist", text: "Main Habit Type", options: HabitType.allCases.map({ $0.text }), selection: $mainHabitType)
        ]
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    confirm(question: "Are you sure you want to sign out?") {
                        Task { await authVM.signOut() }
                    }
                } label: {
                    Text("Logout")
                        .foregroundStyle(Color.custom.red)
                }
            }
            ScrollView {
                VStack(spacing: 15) {
                    VStack(spacing: 8){
                        ZStack {
                            Text(profileVM.safeUser.icon)
                                .font(.system(size: 35))
                                .shadow(color: .black.opacity(0.5), radius: 5)
                        }.padding(10)
                            .background(
                                Circle()
                                    .fill(Color.custom.text)
                            )
                        Text(profileVM.safeUser.name)
                            .foregroundStyle(Color.custom.text)
                            .font(.mySubtitle)
                        Text(profileVM.safeUser.email)
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

            Spacer()
        }.padding()
            .padding(.bottom, 100)
            .background(Color.custom.background)
    }
}

enum SettingsPreferenceItem: Identifiable {
    case toggle(icon: String, text: String, value: Binding<Bool>)
    case picker(icon: String, text: String, options: [String], selection: Binding<String>)
    case custom(icon: String, text: String, view: AnyView)

    var id: String {
        switch self {
        case .toggle(_, let text, _): return "toggle_\(text)"
        case .picker(_, let text, _, _): return "picker_\(text)"
        case .custom(_, let text, _): return "custom_\(text)"
        }
    }
}

struct SettingsCellView: View {
    let item: SettingsPreferenceItem

    var body: some View {
        ZStack {
            switch item {
            case .toggle(let icon, let text, let value):
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.custom.lightGrey))
                        .frame(width: 40)
                    Text(text)
                    Spacer()
                    Toggle("", isOn: value)
                        .labelsHidden()
                        .tint(.custom.primary)
                }
            case .picker(let icon, let text, let options, let selection):
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .frame(width: 40)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.custom.lightGrey))
                    Text(text)
                    Spacer()
                    Menu {
                        ForEach(options, id: \.self) { opt in
                            Button(opt) { selection.wrappedValue = opt }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selection.wrappedValue)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(8)
                    }
                }
            case .custom(_, _, let view):
                view
            }
        }.font(.myBody)
    }
}

//#Preview {
//    SettingsView(currentUser: User(name: "Natanael", email: "natanael.jop@gmail.com"))
//        .environmentObject(AuthViewModel())
//        .preferredColorScheme(.dark)
//}
