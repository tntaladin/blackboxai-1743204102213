import Foundation
import XCTest
@testable import UberCore

final class RideRepositoryTests: XCTestCase {
    var folder: URL!
    override func setUpWithError() throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
    override func tearDownWithError() throws { try FileManager.default.removeItem(at: folder) }
    func repository() throws -> RideRepository { try RideRepository(fileURL: folder.appendingPathComponent("rides.json")) }
    @discardableResult func book(_ repo: RideRepository, user: String = "alice") throws -> Ride {
        try repo.request(userID: user, pickup: "Home", destination: "Station", price: 8, type: .uberX)
    }

    func testFareUsesMilesAndRoundsToCents() {
        XCTAssertEqual(RideType.uberX.fare(distanceMeters: 1609.34), 6.5)
        XCTAssertEqual(RideType.uberBlack.fare(distanceMeters: 0), 20)
        XCTAssertEqual(RideType.uberXL.fare(distanceMeters: 1000), 10.93)
        XCTAssertEqual(RideType.uberX.fare(distanceMeters: .nan), 5)
    }
    func testBookingPersistsAndHistoryIsIsolatedByUser() throws {
        let repo = try repository()
        let alice = try book(repo)
        _ = try book(repo, user: "bob")
        let restored = try repository()
        XCTAssertEqual(restored.rides(for: "alice"), [alice])
        XCTAssertEqual(restored.rides(for: "bob").count, 1)
        XCTAssertTrue(restored.rides(for: "unknown").isEmpty)
    }
    func testDuplicateBookingRejectedUntilTripEnds() throws {
        let repo = try repository()
        let ride = try book(repo)
        XCTAssertThrowsError(try book(repo))
        try repo.transition(id: ride.id, userID: "alice", to: .inProgress)
        try repo.transition(id: ride.id, userID: "alice", to: .completed)
        XCTAssertNoThrow(try book(repo))
    }
    func testCannotCompleteUnstartedTripOrChangeAnotherUsersTrip() throws {
        let repo = try repository()
        let ride = try book(repo)
        XCTAssertThrowsError(try repo.transition(id: ride.id, userID: "alice", to: .completed))
        XCTAssertThrowsError(try repo.transition(id: ride.id, userID: "bob", to: .cancelled))
        XCTAssertEqual(repo.rides.first?.status, .requested)
    }
    func testCancelledTripIsTerminalAndPersists() throws {
        let repo = try repository()
        let ride = try book(repo)
        try repo.transition(id: ride.id, userID: "alice", to: .cancelled)
        XCTAssertThrowsError(try repo.transition(id: ride.id, userID: "alice", to: .inProgress))
        XCTAssertEqual(try repository().rides.first?.status, .cancelled)
    }
    func testInvalidRequestDoesNotPersist() throws {
        let repo = try repository()
        XCTAssertThrowsError(try repo.request(userID: "alice", pickup: "Home", destination: " ", price: 2, type: .uberX))
        XCTAssertThrowsError(try repo.request(userID: "alice", pickup: "Home", destination: "Station", price: .infinity, type: .uberX))
        XCTAssertTrue(repo.rides.isEmpty)
    }
    func testCorruptHistoryIsNotSilentlyOverwritten() throws {
        try Data("broken".utf8).write(to: folder.appendingPathComponent("rides.json"))
        XCTAssertThrowsError(try repository())
    }
    func testSaveFailureDoesNotPublishBooking() throws {
        let blocker = folder.appendingPathComponent("file")
        try Data().write(to: blocker)
        let repo = try RideRepository(fileURL: blocker.appendingPathComponent("rides.json"))
        XCTAssertThrowsError(try book(repo))
        XCTAssertTrue(repo.rides.isEmpty)
    }
}
