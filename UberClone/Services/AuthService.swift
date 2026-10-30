import Foundation
import Combine
import Security

/// Local demo accounts only. A production app must authenticate against a trusted server.
@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var userSession: String?
    @Published private(set) var currentUser: User?
    @Published var storageError: String?
    private struct Account: Codable { let user: User; let password: String }
    private struct Vault: Codable { var accounts: [Account]; var session: String? }
    private var vault = Vault(accounts: [], session: nil)
    private let service: String

    init(service: String = "com.tntaladin.UberClone.demo") {
        self.service = service
        do {
            if let data = try readVault() {
                vault = try JSONDecoder().decode(Vault.self, from: data)
            }
            currentUser = vault.accounts.first { $0.user.id == vault.session }?.user
            userSession = currentUser?.id
        } catch { storageError = "Could not read local accounts: \(error.localizedDescription)" }
    }

    func login(withEmail email: String, password: String) async throws {
        let email = normalize(email)
        guard let account = vault.accounts.first(where: { $0.user.email == email && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        var updated = vault
        updated.session = account.user.id
        try persist(updated)
        currentUser = account.user
        userSession = account.user.id
    }

    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        let email = normalize(email)
        let name = fullname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, email.split(separator: "@", omittingEmptySubsequences: false).count == 2,
              !email.hasPrefix("@"),
              let domain = email.split(separator: "@").last, domain.contains("."),
              !email.contains(" "), password.count >= 8 else { throw AuthError.invalidInput }
        guard !vault.accounts.contains(where: { $0.user.email == email }) else { throw AuthError.duplicateEmail }
        let user = User(id: UUID().uuidString, fullname: name, email: email, accountType: .passenger)
        var updated = vault
        updated.accounts.append(Account(user: user, password: password))
        updated.session = user.id
        try persist(updated)
        currentUser = user
        userSession = user.id
    }

    func signout() {
        var updated = vault
        updated.session = nil
        do {
            try persist(updated)
            userSession = nil
            currentUser = nil
        } catch { storageError = "Could not sign out: \(error.localizedDescription)" }
    }

    private func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service, kSecAttrAccount as String: "local-accounts"]
    }

    private func readVault() throws -> Data? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw AuthError.storage(operation: "read", status: status) }
        return result as? Data
    }

    private func persist(_ updated: Vault) throws {
        let data = try JSONEncoder().encode(updated)
        let status = SecItemUpdate(query as CFDictionary,
                                   [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var request = query
            request[kSecValueData as String] = data
            request[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let addStatus = SecItemAdd(request as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw AuthError.storage(operation: "add", status: addStatus) }
        } else if status != errSecSuccess { throw AuthError.storage(operation: "update", status: status) }
        vault = updated
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials, invalidInput, duplicateEmail
    case storage(operation: String, status: OSStatus)
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "The email or password is incorrect."
        case .invalidInput: return "Enter your name, a valid email, and a password with at least 8 characters."
        case .duplicateEmail: return "An account already exists with this email."
        case let .storage(operation, status): return "Could not access secure storage (\(operation), error \(status)). Please try again."
        }
    }
}
