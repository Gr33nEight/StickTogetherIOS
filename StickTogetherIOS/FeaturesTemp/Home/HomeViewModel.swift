//
//  HomeViewModel.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var pickedHabitListType: HabitListType = .myHabits {
        didSet {
            self.updateVisibleHabits()
        }
    }
    @Published var selectedDate: Date = Date() {
        didSet {
            startListeningToAllHabitEntries()
        }
    }
    @Published var weeklyEntries: [HabitEntry] = []
    @Published private var currentUser: User?
    @Published var visibleWeekDates: [Date] = []
    @Published private var usersById: [String: User] = [:]
    
    @Published private(set) var visibleHabits: [Habit] = []
    @Published private(set) var entries: [HabitEntry] = []
    @Published private(set) var error: String?
    @Published private(set) var hasCompletedInitialLoad = false
    
    private var ownedHabits: [Habit] = []
    private var buddyHabits: [Habit] = []
    private var sharedHabits: [Habit] = []
    
    private var ownedTask: Task<Void, Never>?
    private var buddyTask: Task<Void, Never>?
    private var sharedTask: Task<Void, Never>?
    private var habitEntriesTask: Task<Void, Never>?
    private var missingUsersTask: Task<Void, Never>?
    private var activeHabitEntriesDate: Date?
    private var activeHabitEntryIds: [String]?
    private let loadingManager = LoadingManager.shared
    private var listenerGeneration = 0
    private var initialLoadTokens: [String: UUID] = [:]
    private var loadedHabitEntriesRange: String?
    private var loadingHabitEntriesRange: String?
    
    private let currentUserId: String
    private let listenToOwnedHabits: ListenToHabitsUseCase
    private let listenToBuddyHabits: ListenToHabitsUseCase
    private let listenToSharedHabits: ListenToHabitsUseCase
    private let getUser: GetUserUseCase
    private let toggleHabitCompletion: ToggleHabitCompletionStateUseCase
    private let listenToAllHabitEntriesOnDate: ListenToAllHabitEntriesOnDate
    private var getHabitEntries: GetHabitEntriesFromDateRangeUseCase

    var currentUserName: String {
        currentUser?.name ?? ""
    }
    
    var headerTitle: String {
        guard !currentUserName.isEmpty else { return "\(Date().timeOfDayGreeting)," }
        return "\(Date().timeOfDayGreeting),\n\(currentUserName.capitalized) 👋"
    }

    var habitItems: [HabitListItem] {
        habits(for: selectedDate).map { habit in
            HabitListItem(
                id: habit.id ?? UUID().uuidString,
                habit: habit,
                state: completionState(for: habit, on: selectedDate),
                isOwner: iAmOwner(of: habit.id),
                buddyInfos: makeBuddyInfos(for: habit)
            )
        }
    }
    
    var entriesByHabit: [String: [HabitEntry]] {
        Dictionary(grouping: entries) { $0.habitId }
    }
    
    var weeklyEntriesByHabit: [String: [HabitEntry]] {
        Dictionary(grouping: weeklyEntries) { $0.habitId }
    }
    
    init(
        currentUserId: String,
        listenToOwnedHabits: ListenToHabitsUseCase,
        listenToBuddyHabits: ListenToHabitsUseCase,
        listenToSharedHabits: ListenToHabitsUseCase,
        getUser: GetUserUseCase,
        toggleHabitCompletion: ToggleHabitCompletionStateUseCase,
        listenToAllHabitEntriesOnDate: ListenToAllHabitEntriesOnDate,
        getHabitEntries: GetHabitEntriesFromDateRangeUseCase
    ) {
        self.currentUserId = currentUserId
        self.listenToOwnedHabits = listenToOwnedHabits
        self.listenToBuddyHabits = listenToBuddyHabits
        self.listenToSharedHabits = listenToSharedHabits
        self.getUser = getUser
        self.toggleHabitCompletion = toggleHabitCompletion
        self.listenToAllHabitEntriesOnDate = listenToAllHabitEntriesOnDate
        self.getHabitEntries = getHabitEntries
    }

    func doneHabitsOnDate(_ date: Date) -> Int {
        habits(for: date)
            .filter {
                guard let id = $0.id else { return false }

                return weeklyEntriesByHabit[id]?.contains {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                    && $0.userId == currentUserId
                    && $0.status == .done
                } ?? false
            }
            .count
    }

    func notDoneHabitsOnDate(_ date: Date) -> Int {
        habits(for: date).count - doneHabitsOnDate(date)
    }
    
    func habits(for date: Date) -> [Habit] {
        visibleHabits.filter {
            $0.frequency.occurs(
                on: date,
                startDate: $0.startDate,
                endDate: $0.endDate
            )
        }
    }
    
    func fetchHabitEntries(from startDate: Date, to endDate: Date) async  {
        let key = "\(Calendar.current.startOfDay(for: startDate).timeIntervalSince1970)-\(Calendar.current.startOfDay(for: endDate).timeIntervalSince1970)"
        guard loadedHabitEntriesRange != key,
              loadingHabitEntriesRange != key else { return }
        loadingHabitEntriesRange = key

        do {
            let result = try await loadingManager.run {
                try await getHabitEntries.execute(userId: currentUserId, from: startDate, to: endDate)
            }
            if loadingHabitEntriesRange == key {
                weeklyEntries = result
                loadedHabitEntriesRange = key
            }
        } catch {
            if loadingHabitEntriesRange == key, !(error is CancellationError) {
                self.error = error.localizedDescription
            }
        }
        if loadingHabitEntriesRange == key {
            loadingHabitEntriesRange = nil
        }
    }
    
    private func didComplete(
        habitId: String,
        on date: Date
    ) -> Bool {
        entriesByHabit[habitId]?.contains {
            Calendar.current.isDate($0.date, inSameDayAs: date)
            && $0.userId == currentUserId
            && $0.status == .done
        } ?? false
    }
    
    private func scheduledHabits(on date: Date) -> [Habit] {
        visibleHabits.filter {
            $0.frequency.occurs(
                on: date,
                startDate: $0.startDate
            )
        }
    }

    func onAppear() async {
        startListening()
        if currentUser == nil {
            await getCurrentUser(generation: listenerGeneration)
        }
    }
    
    private func startListening() {
        if ownedTask != nil || buddyTask != nil || sharedTask != nil {
            stopListening()
        }
        beginInitialLoadIfNeeded()
        let generation = listenerGeneration
        ownedTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = try await listenToOwnedHabits.stream(for: currentUserId)
                for try await habits in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.ownedHabits = habits
                    self.updateVisibleHabits()
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("ownedHabits", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("ownedHabits", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                self.error = error.localizedDescription
            }
            finishInitialLoad("ownedHabits", generation: generation)
        }
        
        buddyTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = try await listenToBuddyHabits.stream(for: currentUserId)
                for try await habits in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.buddyHabits = habits
                    self.updateVisibleHabits()
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("buddyHabits", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("buddyHabits", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                self.error = error.localizedDescription
            }
            finishInitialLoad("buddyHabits", generation: generation)
        }
        
        sharedTask = Task { [weak self] in
            guard let self else { return }
            var receivedInitialValue = false
            do {
                let stream = try await listenToSharedHabits.stream(for: currentUserId)
                for try await habits in stream {
                    guard !Task.isCancelled, generation == listenerGeneration else { return }
                    self.sharedHabits = habits
                    self.updateVisibleHabits()
                    if !receivedInitialValue {
                        receivedInitialValue = true
                        finishInitialLoad("sharedHabits", generation: generation)
                    }
                }
            } catch {
                finishInitialLoad("sharedHabits", generation: generation)
                guard !Task.isCancelled, generation == listenerGeneration else { return }
                self.error = error.localizedDescription
            }
            finishInitialLoad("sharedHabits", generation: generation)
        }
    }

    private func beginInitialLoadIfNeeded() {
        guard !hasCompletedInitialLoad, initialLoadTokens.isEmpty else { return }
        var initialSources = ["ownedHabits", "buddyHabits", "sharedHabits"]
        if currentUser == nil { initialSources.append("currentUser") }
        initialLoadTokens = Dictionary(
            uniqueKeysWithValues: initialSources.map { ($0, loadingManager.begin()) }
        )
    }

    private func finishInitialLoad(_ key: String, generation: Int) {
        guard generation == listenerGeneration,
              let token = initialLoadTokens.removeValue(forKey: key) else { return }
        loadingManager.finish(token)
        if initialLoadTokens.isEmpty {
            hasCompletedInitialLoad = true
        }
    }
    
    private func getCurrentUser(generation: Int) async {
        do {
            currentUser = try await getUser.byId(with: currentUserId)
        } catch {
            self.error = error.localizedDescription
        }
        finishInitialLoad("currentUser", generation: generation)
    }
    
    func toggleHabitCompletion(of habitId: String) async {
        let previousEntries = entries
        
        let entryExists = entries.contains {
            $0.habitId == habitId &&
            $0.userId == currentUserId
        }
        
        if entryExists {
            entries.removeAll {
                $0.habitId == habitId &&
                $0.userId == currentUserId
            }
        } else {
            let entry = HabitEntry(
                habitId: habitId,
                userId: currentUserId,
                date: selectedDate,
                status: .done
            )
            entries.append(entry)
        }
        
        do {
            try await loadingManager.run {
                try await toggleHabitCompletion.execute(
                    forHabit: habitId,
                    on: selectedDate,
                    forUser: currentUserId
                )
            }
        } catch {
            entries = previousEntries
            self.error = error.localizedDescription
        }
    }
    
    private func fetchMissingUsers() async {
        let allBuddyIds = Set(
            visibleHabits.flatMap {
                $0.acceptedBuddyIds + $0.invitedBuddyIds
            }
        )

        let missingIds = allBuddyIds.filter {
            usersById[$0] == nil
        }

        guard !missingIds.isEmpty else { return }

        do {
            let users = try await withThrowingTaskGroup(
                of: User.self
            ) { group in

                for id in missingIds {
                    group.addTask {
                        try await self.getUser.byId(with: id)
                    }
                }

                var result: [User] = []

                for try await user in group {
                    result.append(user)
                }

                return result
            }

            users.forEach {
                usersById[$0.id ?? ""] = $0
            }

        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func makeBuddyInfos(
        for habit: Habit
    ) -> [HabitCellBuddyInfo] {

        let habitEntries = (entriesByHabit[habit.id ?? ""] ?? []).filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        let doneUserIds = Set(
            habitEntries
                .filter { $0.status == .done }
                .map(\ .userId)
        )

        let accepted = habit.acceptedBuddyIds.map { id in

            let name = usersById[id]?.name ?? "Unknown"
            let buddyDidComplete = doneUserIds.contains(id)
            let participants = Set([habit.ownerId] + habit.acceptedBuddyIds)
            let allDone = participants.isSubset(of: doneUserIds)

            let isPastAndNotDone =
                selectedDate < Calendar.current.startOfDay(for: Date())
                && !allDone

            let buddyStatusColor: Color = {
                if allDone || isPastAndNotDone {
                    return .custom.text
                }

                return buddyDidComplete
                    ? .custom.primary
                    : .custom.red
            }()
            
            let buddyBadgeColor: Color = {
                if allDone {
                    return buddyDidComplete
                        ? .custom.primary
                        : .custom.red
                }

                return isPastAndNotDone
                    ? .custom.red
                    : .custom.text
            }()
            
            return HabitCellBuddyInfo(
                id: id,
                buddyStatusColor: buddyStatusColor,
                buddyBadgeColor: buddyBadgeColor,
                buddyName: name,
                showStatusBadge: buddyDidComplete
                    ? .checkmark
                    : .xmark
            )
        }

        let invited = habit.invitedBuddyIds.map { id in

            let name = usersById[id]?.name ?? "Unknown"

            return HabitCellBuddyInfo(
                id: id,
                buddyStatusColor: .custom.text,
                buddyBadgeColor: .custom.text,
                buddyName: name,
                showStatusBadge: .invited
            )
        }

        return Array(Set(accepted + invited))
    }
    
    private func startListeningToAllHabitEntries() {
        let date = Calendar.current.startOfDay(for: selectedDate)
        let habitIds = visibleHabits.compactMap(\.id).sorted()
        guard activeHabitEntriesDate != date || activeHabitEntryIds != habitIds else { return }

        let previousTask = habitEntriesTask
        previousTask?.cancel()
        activeHabitEntriesDate = date
        activeHabitEntryIds = habitIds

        habitEntriesTask = Task { [weak self] in
            guard let self else { return }
            // Tear down the old Firestore stream before opening another one.
            // Fast date/tab changes can otherwise briefly stack chunk listeners.
            if let previousTask {
                await previousTask.value
            }
            guard !Task.isCancelled,
                  self.activeHabitEntriesDate == date,
                  self.activeHabitEntryIds == habitIds else { return }

            do {
                let stream = try await listenToAllHabitEntriesOnDate.stream(date: date, habitIds: habitIds)
                for try await entries in stream {
                    guard !Task.isCancelled else { return }
                    self.entries = entries
                }
            } catch is CancellationError {
                return
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    private func stopListeningToAllHabitEntries() {
        activeHabitEntriesDate = nil
        activeHabitEntryIds = nil
        habitEntriesTask?.cancel()
        habitEntriesTask = nil
    }
    
    private func iAmOwner(of habitId: String?) -> Bool {
        ownedHabits.contains(where: { $0.id == habitId })
    }
    
    private func completionState(for habit: Habit, on date: Date) -> CompletionState {
        let entries = (entriesByHabit[habit.id ?? ""] ?? []).filter {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }
        let participants = Set([habit.ownerId] + habit.acceptedBuddyIds)
        let doneUserIds = Set(entries.map { $0.userId })
        
        if doneUserIds.isEmpty { return .none }
        
        let meDone = doneUserIds.contains(currentUserId)
        let allDone = participants.isSubset(of: doneUserIds)
        
        if allDone { return .all }
        if meDone && doneUserIds.count > 1 { return .meAndOthers }
        if meDone { return .onlyMe }
        
        return .onlyOthers
    }
    
    private func updateVisibleHabits() {
        switch pickedHabitListType {
        case .myHabits:
            self.visibleHabits = ownedHabits + buddyHabits
        case .friendsHabits:
            self.visibleHabits = sharedHabits
        }
        
        if missingUsersTask == nil {
            missingUsersTask = Task { [weak self] in
                guard let self else { return }
                await self.fetchMissingUsers()
                self.missingUsersTask = nil
            }
        }
        
        startListeningToAllHabitEntries()
    }
    
    func stopListening() {
        listenerGeneration += 1
        ownedTask?.cancel()
        buddyTask?.cancel()
        sharedTask?.cancel()
        stopListeningToAllHabitEntries()
        
        ownedTask = nil
        buddyTask = nil
        sharedTask = nil
        for token in initialLoadTokens.values {
            loadingManager.finish(token)
        }
        initialLoadTokens.removeAll()
    }
    
    deinit {
        ownedTask?.cancel()
        buddyTask?.cancel()
        sharedTask?.cancel()
    }
}

struct HabitListItem: Identifiable {
    let id: String
    let habit: Habit
    let state: CompletionState
    let isOwner: Bool
    let buddyInfos: [HabitCellBuddyInfo]
}
