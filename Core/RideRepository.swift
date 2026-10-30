import Foundation

/// Saves before publishing changes so a disk failure never looks like a successful booking.
public final class RideRepository {
    public private(set) var rides: [Ride]
    private let fileURL: URL

    public init(fileURL: URL) throws {
        self.fileURL = fileURL
        if FileManager.default.fileExists(atPath: fileURL.path) {
            rides = try JSONDecoder().decode([Ride].self, from: Data(contentsOf: fileURL))
        } else {
            rides = []
        }
    }

    public func rides(for userID: String) -> [Ride] {
        rides.filter { $0.userID == userID }.sorted { $0.date > $1.date }
    }

    @discardableResult
    public func request(userID: String, pickup: String, destination: String,
                        price: Double, type: RideType) throws -> Ride {
        guard !userID.isEmpty, !pickup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              price.isFinite, price >= 0 else { throw RideError.invalidRequest }
        guard !rides(for: userID).contains(where: { $0.status.isActive }) else {
            throw RideError.activeRideExists
        }
        let ride = Ride(userID: userID, pickupLocation: pickup,
                        dropoffLocation: destination, price: price, type: type)
        try save(rides + [ride])
        return ride
    }

    public func transition(id: UUID, userID: String, to status: RideStatus) throws {
        guard let index = rides.firstIndex(where: { $0.id == id && $0.userID == userID }) else {
            throw RideError.missingRide
        }
        var updated = rides
        try updated[index].transition(to: status)
        try save(updated)
    }

    private func save(_ updated: [Ride]) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try JSONEncoder().encode(updated).write(to: fileURL, options: .atomic)
        rides = updated
    }
}
