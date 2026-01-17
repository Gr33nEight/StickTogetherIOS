//
//  HabitViewModelTests.swift
//  StickTogetherIOSTests
//
//  Created by Natanael Jop on 17/01/2026.
//

import XCTest
@testable import StickTogetherIOS

@MainActor
final class HabitViewModelTests: XCTestCase {

    private var service: MockHabitService!
    private var vm: HabitViewModel!
    private var currentUser: User!

    override func setUp() async throws {
        service = MockHabitService()
        currentUser = User(
            id: "user-1",
            name: "Test User",
            email: "test@test.com"
        )

        vm = HabitViewModel(
            service: service,
            loading: nil,
            currentUser: currentUser
        )
    }

    override func tearDown() async throws {
        service = nil
        vm = nil
        currentUser = nil
    }

    func testStartListening_loadsUserAndFriendsHabits() async {
        // given
        let myHabit = Habit.mock(
            ownerId: currentUser.safeID
        )

        let friendHabit = Habit.mock(
            ownerId: "friend-1",
            buddyId: currentUser.safeID,
            type: .coop
        )

        _ = try? await service.createHabit(myHabit)
        _ = try? await service.createHabit(friendHabit)

        // when
        await vm.startListening()

        // then
        XCTAssertEqual(vm.habits.count, 2)
        XCTAssertEqual(vm.friendsHabits.count, 1)
    }

    func testCreateHabit_appendsHabitAndReturnsSuccess() async {
        // given
        let habit = Habit.mock(ownerId: currentUser.safeID)

        // when
        let result = await vm.createHabit(habit)

        // then
        XCTAssertEqual(result, .success)
        XCTAssertEqual(vm.habits.count, 1)
        XCTAssertEqual(vm.habits.first?.title, habit.title)
    }

    func testGetHabitById_returnsHabit() async {
        // given
        let habit = Habit.mock(ownerId: currentUser.safeID)
        let saved = try? await service.createHabit(habit)

        // when
        let result = await vm.getHabitById(saved!.id!)

        // then
        switch result {
        case .value(let fetched):
            XCTAssertEqual(fetched?.id, saved?.id)
        default:
            XCTFail("Expected habit value")
        }
    }

    func testGetHabitById_returnsNilWhenNotFound() async {
        // when
        let result = await vm.getHabitById("missing-id")

        // then
        switch result {
        case .value(let habit):
            XCTAssertNil(habit)
        default:
            XCTFail("Expected nil value")
        }
    }

    func testUpdateHabit_updatesLocalHabit() async {
        // given
        var habit = Habit.mock(ownerId: currentUser.safeID)
        habit = try! await service.createHabit(habit)

        await vm.startListening()

        habit.title = "Updated Title"

        // when
        await vm.updateHabit(habit)

        // then
        XCTAssertEqual(vm.habits.first?.title, "Updated Title")
    }

    func testDeleteHabit_removesHabit() async {
        // given
        let habit = try! await service.createHabit(
            Habit.mock(ownerId: currentUser.safeID)
        )

        await vm.startListening()

        // when
        let result = await vm.deleteHabit(habit.id)

        // then
        XCTAssertEqual(result, .success)
        XCTAssertTrue(vm.habits.isEmpty)
    }

    func testDeleteHabit_withNilId_returnsError() async {
        // when
        let result = await vm.deleteHabit(nil)

        // then
        if case .error = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error")
        }
    }

    func testMarkHabitAsCompleted_marksCompletion() async {
        // given
        let date = Date()
        var habit = Habit.mock(ownerId: currentUser.safeID)
        habit = try! await service.createHabit(habit)

        await vm.startListening()

        // when
        await vm.markHabitAsCompleted(habit, date: date)

        let updated = try! await service.fetchHabit(byId: habit.id!)!

        // then
        let key = Habit.dayKey(for: date)
        XCTAssertTrue(updated.completion[key]?.contains(currentUser.safeID) == true)
    }

    func testCurrentUserDidComplete_returnsTrue() {
        // given
        let date = Date()
        let key = Habit.dayKey(for: date)

        let habit = Habit.mock(
            ownerId: currentUser.safeID,
            completion: [key: [currentUser.safeID]]
        )

        // when
        let result = vm.currentUserDidComplete(habit, on: date)

        // then
        XCTAssertTrue(result)
    }

    func testHabitState_done() {
        // given
        let date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-86400)
        let key = Habit.dayKey(for: date)

        let habit = Habit.mock(
            ownerId: currentUser.safeID,
            completion: [key: [currentUser.safeID]],
            type: .alone
        )

        // when
        let state = vm.habitState(habit, on: date)

        // then
        XCTAssertEqual(state, .done)
    }

    func testHabitState_skipped() {
        // given
        let date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-86400)

        let habit = Habit.mock(ownerId: currentUser.safeID)

        // when
        let state = vm.habitState(habit, on: date)

        // then
        XCTAssertEqual(state, .skipped)
    }

    func testHabitStats_countsDoneAndSkipped() async {
        // given
        let date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-86400)
        let key = Habit.dayKey(for: date)

        let doneHabit = Habit.mock(
            ownerId: currentUser.safeID,
            completion: [key: [currentUser.safeID]],
            type: .alone
        )

        let skippedHabit = Habit.mock(
            ownerId: currentUser.safeID
        )

        _ = try? await service.createHabit(doneHabit)
        _ = try? await service.createHabit(skippedHabit)

        await vm.startListening()

        // when
        let stats = vm.habitStats(on: date)

        // then
        XCTAssertEqual(stats.done, 1)
        XCTAssertEqual(stats.skipped, 1)
    }
}

extension Habit {

    static func mock(
        id: String? = nil,
        ownerId: String,
        buddyId: String = "",
        completion: [String: [String]] = [:],
        type: HabitType = .alone
    ) -> Habit {

        Habit(
            id: id,
            title: "Test Habit",
            icon: "🔥",
            ownerId: ownerId,
            buddyId: buddyId,
            frequency: .daily(),
            startDate: Calendar.current.startOfDay(for: Date().addingTimeInterval(-864000)),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            reminderTime: nil,
            createdAt: Date(),
            completion: completion,
            type: type
        )
    }
}

extension SuccessOrError: @retroactive Equatable {
    public static func == (lhs: SuccessOrError, rhs: SuccessOrError) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case let (.error(a), .error(b)): return a == b
        default: return false
        }
    }
}
