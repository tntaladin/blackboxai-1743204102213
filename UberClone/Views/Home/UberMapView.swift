import SwiftUI
import MapKit

struct UberMapView: UIViewRepresentable {
    @EnvironmentObject private var locationService: LocationService

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.setRegion(locationService.region, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let coordinator = context.coordinator
        let destinationID = locationService.selectedLocation?.id
        let route = locationService.route
        let routeID = route.map { ObjectIdentifier($0) }
        let pickup = locationService.pickupCoordinate
        let pickupChanged = coordinator.pickup?.latitude != pickup.latitude || coordinator.pickup?.longitude != pickup.longitude
        guard coordinator.destinationID != destinationID || coordinator.routeID != routeID || pickupChanged else { return }
        coordinator.destinationID = destinationID
        coordinator.routeID = routeID
        coordinator.pickup = pickup
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations.filter { !($0 is MKUserLocation) })
        if locationService.usingDemoLocation {
            let pin = MKPointAnnotation()
            pin.title = "Demo pickup"
            pin.coordinate = pickup
            map.addAnnotation(pin)
        }
        if let destination = locationService.selectedLocation {
            let pin = MKPointAnnotation()
            pin.title = destination.title
            pin.coordinate = destination.coordinate
            map.addAnnotation(pin)
        }
        if let route {
            map.addOverlay(route.polyline)
            map.setVisibleMapRect(route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 100, left: 40, bottom: 80, right: 40), animated: true)
        } else if destinationID == nil {
            map.setRegion(locationService.region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator: NSObject, MKMapViewDelegate {
        var destinationID: UUID?
        var routeID: ObjectIdentifier?
        var pickup: CLLocationCoordinate2D?
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
