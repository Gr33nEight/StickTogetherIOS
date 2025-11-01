//
//  ToastMessage.swift
//  PanstwaMiasta
//
//  Created by Natanael Jop on 01/11/2023.
//

import SwiftUI

struct ToastMessageView: View {
    @Binding var toast: ToastMessage?
    @State var delegator: ToastDelegator = ToastDelegator()
    @GestureState private var translation: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var showProgressBar = false
    
    var body: some View {
        ZStack {
            if delegator.show {
                HStack(spacing: 0) {
                    delegator.currentType.color
                        .frame(width: 8)
                    VStack {
                        HStack(alignment: .top, spacing: 10) {
                            delegator.currentType.icon
                                .font(.mySubtitle)
                                .foregroundColor(delegator.currentType.color)
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey( delegator.currentType.title))
                                    .font(.mySubtitle)
                                    .foregroundStyle(delegator.currentType.color)
                                Text(delegator.currentType.content)
                                    .foregroundStyle(Color.custom.text)
                                    .font(.customAppFont(size: 16, weight: .medium))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Button(action: { delegator.hide(); toast = nil }) {
                                Image(systemName: "xmark")
                                    .font(.mySubtitle)
                                    .foregroundStyle(Color.custom.text)
                            }
                        }
                    }.padding()
                    .padding(.top, 10)
                    .background(Color.custom.background)
                }
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(5)
                .padding(.horizontal, 10)
                .padding(.top, 70)
                .shadow(radius: 5)
                .transition(.move(edge: .top))
                .offset(y: translation + offset - 10)
                .animation(.linear, value: translation)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating(self.$translation) { value, state, _ in
                            if translation < 15 {
                                state = value.translation.height
                                DispatchQueue.main.async {
                                    toast = nil
                                }
                            }

                        }.onEnded { value in
                            withAnimation {
                                guard value.translation.height < 0 else {
                                    return
                                }
                                self.delegator.hide()
                                DispatchQueue.main.async {
                                    toast = nil
                                }
                            }
                        }
                )
            }
        }.ignoresSafeArea()
        .onReceive(delegator.timer.timer) { _ in
            if delegator.timer.timeLeft > 0 {
                delegator.timer.decrementTime()
            } else {
                delegator.timer.cancelTimer()
                delegator.hide()
                toast = nil
            }
        }
        .onChange(of: toast) { _, _ in
            if let toast = toast {
                delegator.present(toast)
            }
        }
    }
}
