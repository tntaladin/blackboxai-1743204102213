import Foundation

public enum RideType: String, CaseIterable, Codable, Identifiable, Sendable {
    case uberX, uberBlack, uberXL
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .uberX: return "UberX"
        case .uberBlack: return "Uber Black"
        case .uberXL: return "UberXL"
        }
    }
    public var capacity: Int { self == .uberXL ? 6 : 4 }
    public var baseFare: Double {
        switch self {
        case .uberX: return 5
        case .uberBlack: return 20
        case .uberXL: return 10
        }
    }
    public func fare(distanceMeters: Double) -> Double {
        guard distanceMeters.isFinite, distanceMeters >= 0 else { return baseFare }
        return ((baseFare + distanceMeters / 1609.34 * 1.5) * 100).rounded() / 100
    }
}

public enum RideStatus: String, Codable, Sendable {
    case requested, inProgress, completed, cancelled
    public var title: String {
        switch self {
        case .requested: return "Driver requested"
        case .inProgress: return "On your way"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    public var isActive: Bool { self == .requested || self == .inProgress }
}

public struct Ride: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let userID: String
    public let pickupLocation: String
    public let dropoffLocation: String
    public let date: Date
    public let price: Double
    public let type: RideType
    public private(set) var status: RideStatus

    public init(userID: String, pickupLocation: String, dropoffLocation: String,
                price: Double, type: RideType, date: Date = Date()) {
        id = UUID()
        self.userID = userID
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.price = price
        self.type = type
        self.date = date
        status = .requested
    }

    public mutating func transition(to next: RideStatus) throws {
        switch (status, next) {
        case (.requested, .inProgress), (.requested, .cancelled),
             (.inProgress, .completed), (.inProgress, .cancelled): status = next
        default: throw RideError.invalidTransition
        }
    }
}

public enum RideError: Error, LocalizedError {
    case invalidTransition, activeRideExists, invalidRequest, missingRide
    public var errorDescription: String? {
        switch self {
        case .invalidTransition: return "This trip cannot change to that status."
        case .activeRideExists: return "Finish or cancel your current trip first."
        case .invalidRequest: return "Choose a destination and a valid fare first."
        case .missingRide: return "This trip could not be found."
        }
    }
}
