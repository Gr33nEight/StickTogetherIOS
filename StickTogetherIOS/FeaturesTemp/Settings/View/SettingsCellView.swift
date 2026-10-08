//
//  SettingsCellView.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 19/03/2026.
//
import SwiftUI

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
