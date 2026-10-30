import Foundation

enum AccountType: Int, Codable { case passenger, driver }

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let accountType: AccountType
}
