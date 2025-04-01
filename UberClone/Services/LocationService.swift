import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Mock location data for San Francisco area
    private let mockLocations: [String: CLLocationCoordinate2D] = [
        "Golden Gate Bridge": CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783),
        "Union Square": CLLocationCoordinate2D(latitude: 37.7880, longitude: -122.4075),
        "Fisherman's Wharf": CLLocationCoordinate2D(latitude: 37.8080, longitude: -122.4177),
        "Test Location": CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    ]
    
    // Simulate location updates
    func startMockLocationUpdates() {
        // Set initial location
        userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        region.center = userLocation!
        
        // Simulate movement every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let latOffset = Double.random(in: -0.001...0.001)
            let longOffset = Double.random(in: -0.001...0.001)
            self.userLocation?.latitude += latOffset
            self.userLocation?.longitude += longOffset
            self.region.center = self.userLocation!
        }
    }
    
    // Mock location search
    func searchLocations(query: String) async throws -> [LocationItem] {
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        
        return mockLocations
            .filter { $0.key.lowercased().contains(query.lowercased()) }
            .map { LocationItem(title: $0.key, coordinate: $0.value) }
    }
    
    // Mock route calculation
    func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D] {
        // Simple straight line interpolation
        let steps = 10
        var route = [CLLocationCoordinate2D]()
        
        for i in 0...steps {
            let lat = from.latitude + (to.latitude - from.latitude) * Double(i)/Double(steps)
            let long = from.longitude + (to.longitude - from.longitude) * Double(i)/Double(steps)
            route.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
        
        return route
    }
}


struct LocationItem: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}
