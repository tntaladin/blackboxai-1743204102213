import Foundation
import Combine
import UberCore

@MainActor
final class TripStore: ObservableObject {
    @Published private(set) var rides: [Ride] = []
    @Published var errorMessage: String?
    private var repository: RideRepository?

    init() {
        do {
            let folder = try FileManager.default.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: nil, create: true)
            repository = try RideRepository(fileURL: folder.appendingPathComponent("UberClone/rides.json"))
            rides = repository?.rides ?? []
        } catch { errorMessage = "Could not load trips: \(error.localizedDescription)" }
    }

    func history(for userID: String) -> [Ride] {
        rides.filter { $0.userID == userID }.sorted { $0.date > $1.date }
    }

    func activeRide(for userID: String) -> Ride? {
        history(for: userID).first { $0.status.isActive }
    }

    func request(userID: String, pickup: String, destination: String, price: Double, type: RideType) -> Bool {
        perform { repo in
            _ = try repo.request(userID: userID, pickup: pickup, destination: destination, price: price, type: type)
        }
    }

    func transition(_ ride: Ride, userID: String, to status: RideStatus) {
        _ = perform { try $0.transition(id: ride.id, userID: userID, to: status) }
    }

    private func perform(_ action: (RideRepository) throws -> Void) -> Bool {
        guard let repository else {
            errorMessage = "Trip storage is unavailable. Restart the app and try again."
            return false
        }
        do {
            try action(repository)
            rides = repository.rides
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
