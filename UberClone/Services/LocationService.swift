import Foundation
import Combine
import CoreLocation
import MapKit

struct LocationItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    init(title: String, subtitle: String = "", coordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var selectedLocation: LocationItem?
    @Published private(set) var route: MKRoute?
    @Published private(set) var routeError: String?
    @Published private(set) var isRouting = false
    @Published private(set) var usingDemoLocation = true
    @Published private(set) var locationMessage: String?
    private let manager = CLLocationManager()
    private var directions: MKDirections?
    private var requestID = UUID()

    var pickupCoordinate: CLLocationCoordinate2D { userLocation ?? region.center }
    var distanceMeters: Double? { route?.distance }
    var arrivalText: String {
        guard let route else { return "" }
        return "About \(max(1, Int(ceil(route.expectedTravelTime / 60)))) min"
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        default: locationMessage = "Location access is off. Use the San Francisco demo pickup or enable access in Settings."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        region.center = location.coordinate
        usingDemoLocation = false
        locationMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationMessage = "Could not get your location. You can use the demo pickup instead."
    }

    func searchLocations(query: String) async throws -> [LocationItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        let search = MKLocalSearch(request: request)
        let response = try await withTaskCancellationHandler {
            try await search.start()
        } onCancel: { search.cancel() }
        try Task.checkCancellation()
        return response.mapItems.map {
            LocationItem(title: $0.name ?? "Destination", subtitle: $0.placemark.title ?? "",
                         coordinate: $0.placemark.coordinate)
        }
    }

    var demoDestinations: [LocationItem] {
        [LocationItem(title: "Golden Gate Bridge", subtitle: "San Francisco demo destination",
                      coordinate: .init(latitude: 37.8199, longitude: -122.4783)),
         LocationItem(title: "Union Square", subtitle: "San Francisco demo destination",
                      coordinate: .init(latitude: 37.7880, longitude: -122.4075))]
    }

    func select(_ item: LocationItem) async {
        clearSelection()
        selectedLocation = item
        await loadRoute()
    }

    func loadRoute() async {
        guard let destination = selectedLocation else { return }
        directions?.cancel()
        let token = UUID()
        requestID = token
        route = nil
        routeError = nil
        isRouting = true
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        self.directions = directions
        defer { if token == requestID { isRouting = false } }
        do {
            let response = try await withTaskCancellationHandler {
                try await directions.calculate()
            } onCancel: { directions.cancel() }
            try Task.checkCancellation()
            guard requestID == token else { return }
            guard let route = response.routes.first else {
                routeError = "No driving route is available for this destination."
                return
            }
            self.route = route
        } catch {
            guard requestID == token, !Task.isCancelled else { return }
            routeError = "Could not load a driving route. Check your connection and retry."
        }
    }

    func clearSelection() {
        requestID = UUID()
        directions?.cancel()
        directions = nil
        selectedLocation = nil
        route = nil
        routeError = nil
        isRouting = false
    }
}
