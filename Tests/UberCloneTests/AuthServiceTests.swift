import XCTest
import Security
@testable import UberClone

final class AuthServiceTests: XCTestCase {
    private var serviceID: String!
    override func setUp() { serviceID = "com.tntaladin.UberClone.tests." + UUID().uuidString }
    override func tearDown() {
        SecItemDelete([kSecClass as String: kSecClassGenericPassword,
                       kSecAttrService as String: serviceID!] as CFDictionary)
    }
    @MainActor func testRegistrationSurvivesServiceRecreationAndCanSignBackIn() async throws {
        let email = "test-\(UUID().uuidString)@example.com"
        let service = AuthService(service: serviceID)
        try await service.createUser(withEmail: "  \(email.uppercased())  ", password: "DemoPass123!", fullname: " Demo User ")
        let id = try XCTUnwrap(service.userSession)
        XCTAssertEqual(service.currentUser?.fullname, "Demo User")
        let restored = AuthService(service: serviceID)
        XCTAssertEqual(restored.userSession, id)
        restored.signout()
        XCTAssertNil(restored.userSession)
        XCTAssertNil(AuthService(service: serviceID).userSession)
        try await restored.login(withEmail: email, password: "DemoPass123!")
        XCTAssertEqual(restored.userSession, id)
        do {
            try await restored.login(withEmail: email, password: "incorrect")
            XCTFail("Wrong password was accepted")
        } catch { XCTAssertEqual(restored.userSession, id) }
        do {
            try await restored.createUser(withEmail: email, password: "DemoPass123!", fullname: "Duplicate")
            XCTFail("Duplicate registration was accepted")
        } catch { }
        restored.signout()
    }
    @MainActor func testInvalidRegistrationRejected() async {
        let service = AuthService(service: serviceID)
        do {
            try await service.createUser(withEmail: "invalid", password: "short", fullname: " ")
            XCTFail("Invalid registration was accepted")
        } catch { }
    }
}
