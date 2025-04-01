import Foundation

class AuthService: ObservableObject {
    /// Tracks the current user session ID
    @Published var userSession: String?
    
    /// Contains the currently logged in user
    @Published var currentUser: User?
    
    // Static mock database that persists between AuthService instances
    private static var mockUsers: [String: User] = {
        let testUser = User(
            id: "mock123",
            fullname: "Test User",
            email: "test@example.com",
            accountType: .passenger
        )
        return [testUser.id: testUser]
    }()
    
    /// Mock login function
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func login(withEmail email: String, password: String) async throws {
        if email == "test@example.com" && password == "password" {
            userSession = "mock123"
            currentUser = Self.mockUsers["mock123"]
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    /// Mock user registration
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        let newUser = User(
            id: UUID().uuidString,
            fullname: fullname,
            email: email,
            accountType: .passenger
        )
        Self.mockUsers[newUser.id] = newUser
        userSession = newUser.id
        currentUser = newUser
    }
    
    /// Ends the current user session
    func signout() {
        userSession = nil
        currentUser = nil
    }
}

enum AuthError: Error {
    case invalidCredentials
}
