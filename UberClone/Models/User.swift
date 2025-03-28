import Foundation
import FirebaseFirestoreSwift

enum AccountType: Int, Codable {
    case passenger
    case driver
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let fullname: String
    let email: String
    let accountType: AccountType
    var homeLocation: SavedLocation?
    var workLocation: SavedLocation?
    var coordinates: GeoPoint?
}

struct SavedLocation: Codable {
    let title: String
    let address: String
    let coordinates: GeoPoint
}