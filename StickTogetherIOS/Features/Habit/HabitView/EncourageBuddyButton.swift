//
//  EncourageBuddyButton.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 01/02/2026.
//

import SwiftUI

struct EncourageBuddyButton: View {
    @Environment(\.showToastMessage) var showToastMessage
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var appNotificationsVM: AppNotificationsViewModel
    @AppStorage("encourageData") var encourageData: Data = Data()
    let habit: Habit
    @State var timeLeft: Int = 0
    @State private var timer: Timer?
    
    var hours: Int {Int(timeLeft) / 3600}
    var minutes: Int {(Int(timeLeft) % 3600) / 60}
    
    private let cooldown: TimeInterval = 60 * 60 * 24
    
    var body: some View {
        Button {
            Task {
                await encourageYourBuddy()
            }
        } label: {
            Text(buttonTitle)
        }
        .customButtonStyle(timeLeft <= 0 ? .secondary : .disabled)
        .onAppear {
            updateTimeLeft()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var buttonTitle: String {
        if timeLeft <= 0 {
            return "Encourage your buddy"
        }

        return "Encourage again in \(hours)h \(minutes)m"
    }
    
    private func encourageYourBuddy() async {
        guard timeLeft <= 0 else {
            showToastMessage(.info("You can encourage your buddy again in \(hours)h \(minutes)m"))
            return
        }
        guard let receiverId = habit.otherId(of: profileVM.safeUser.safeID) else { return }

        let notification = AppNotification.encouragement(
            senderId: profileVM.safeUser.safeID,
            receiverId: receiverId,
            senderName: profileVM.safeUser.name,
            habitId: habit.id ?? "",
            content: "Rusz w końcu tą dupę!"
        )

        saveEncouragementDate()
        updateTimeLeft()

        await appNotificationsVM.sendAppNotification(notification)
    }
    
    private func saveEncouragementDate() {
        guard let habitId = habit.id else { return }

        var dict = loadEncourageDictionary()
        dict[habitId] = Date()

        if let data = try? JSONEncoder().encode(dict) {
            encourageData = data
        }
    }
    
    private func updateTimeLeft() {
        guard let habitId = habit.id else {
            timeLeft = 0
            return
        }

        print(habitId)
        let dict = loadEncourageDictionary()
        guard let lastDate = dict[habitId] else {
            return
        }
        
        print(lastDate)

        let endDate = lastDate.addingTimeInterval(cooldown)
        
        print(endDate)
        timeLeft = Int(max(0, endDate.timeIntervalSinceNow))
        print(timeLeft)
    }
    
    private func startTimer() {
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                updateTimeLeft()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func loadEncourageDictionary() -> [String: Date] {
        guard
            !encourageData.isEmpty,
            let dict = try? JSONDecoder().decode([String: Date].self, from: encourageData)
        else {
            return [:]
        }
        return dict
    }
}

#Preview {
    EncourageBuddyButton(habit: Habit(title: "Test", icon: "", ownerId: "", frequency: Frequency(type: .daily))).preferredColorScheme(.dark)
        .environmentObject(ProfileViewModel(profileService: MockProfileService()))
        .environmentObject(AppNotificationsViewModel(service: FirebaseAppNotificationService(), currentUser: User(name: "", email: "")))
}
