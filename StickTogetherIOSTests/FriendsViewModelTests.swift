//
//  FriendsViewModelTests.swift
//  StickTogetherIOSTests
//
//  Created by Natanael Jop on 12/01/2026.
//

@testable import StickTogetherIOS
import XCTest

@MainActor
final class FriendsViewModelTests: XCTestCase {

    private var vm: FriendsViewModel!
    private var friendsService: MockFriendsService!
    private var profileService: MockProfileService!
    private var currentUser: User!

    override func setUp() async throws {
        friendsService = MockFriendsService()
        profileService = MockProfileService()

        await profileService.setStoredUser(currentUser)

        let currentUser = User(
            id: "me",
            name: "Me",
            email: "me@gmail.com"
        )

        vm = FriendsViewModel(
            profileService: profileService,
            friendsService: friendsService,
            currentUserId: currentUser.id!
        )
    }

    func testAcceptInvitation_success() async {
        // given
        let invitation = Invitation(
            id: "inv1",
            senderId: "friend123",
            receiverId: "me"
        )

        // when
        let result = await vm.acceptInvitation(invitation: invitation)

        // then
        XCTAssertSuccess(result)

        let added = await friendsService.getAddedFriends()
        XCTAssertEqual(added.count, 2)

        XCTAssertTrue(added.contains { $0.friendId == "friend123" && $0.userId == "me" })
        XCTAssertTrue(added.contains { $0.friendId == "me" && $0.userId == "friend123" })
    }

    func testDeclineInvitation_deletesInvitationOnly() async {
        // given
        let invitation = Invitation(
            id: "inv1",
            senderId: "friend123",
            receiverId: "me"
        )

        try? await friendsService.sendInvitation(invitation)

        // when
        let result = await vm.declineInvitation(with: "inv1")

        // then
        XCTAssertSuccess(result)

        let remaining = try? await friendsService.fetchAllUsersInvitation(for: "me")
        XCTAssertTrue(remaining?.isEmpty == true)

        let added = await friendsService.getAddedFriends()
        XCTAssertTrue(added.isEmpty)
    }

    func testRemoveFriend_callsServiceForBothUsers() async {
        // when
        let result = await vm.removeFromFriendsList(userId: "friend123")

        // then
        XCTAssertSuccess(result)

        let removed = await friendsService.getRemovedFriends()
        XCTAssertEqual(removed.count, 2)

        XCTAssertTrue(removed.contains { $0.friendId == "friend123" && $0.userId == "me" })
        XCTAssertTrue(removed.contains { $0.friendId == "me" && $0.userId == "friend123" })
    }
    
    func XCTAssertSuccess(
        _ result: SuccessOrError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if case .error(let message) = result {
            XCTFail("Expected success, got error: \(message)", file: file, line: line)
        }
    }
}
