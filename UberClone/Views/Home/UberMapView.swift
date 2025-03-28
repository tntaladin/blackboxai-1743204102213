import SwiftUI
import MapKit

struct UberMapView: UIViewRepresentable {
    @EnvironmentObject var locationService: LocationService
    @Binding var mapState: MapViewState
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        switch mapState {
        case .noInput:
            context.coordinator.clearMapView(uiView)
            uiView.setRegion(locationService.region, animated: true)
            
        case .searchingForLocation:
            break
            
        case .locationSelected:
            if let selectedLocation = locationService.selectedLocation {
                context.coordinator.addAndSelectAnnotation(
                    withCoordinate: selectedLocation.coordinate,
                    mapView: uiView
                )
                context.coordinator.configurePolyline(
                    withDestinationCoordinate: selectedLocation.coordinate,
                    mapView: uiView
                )
            }
            
        case .polylineAdded:
            break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension UberMapView {
    class MapCoordinator: NSObject, MKMapViewDelegate {
        let parent: UberMapView
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        
        init(parent: UberMapView) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            self.currentRegion = region
            parent.locationService.region = region
            mapView.setRegion(region, animated: true)
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D, mapView: MKMapView) {
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D, mapView: MKMapView) {
            guard let userLocationCoordinate = self.userLocationCoordinate else { return }
            parent.locationService.getRoute(
                from: userLocationCoordinate,
                to: coordinate
            ) { route in
                mapView.addOverlay(route.polyline)
                self.parent.mapState = .polylineAdded
                let rect = mapView.mapRectThatFits(
                    route.polyline.boundingMapRect,
                    edgePadding: .init(
                        top: 64,
                        left: 32,
                        bottom: 500,
                        right: 32
                    )
                )
                mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        func clearMapView(_ mapView: MKMapView) {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

enum MapViewState {
    case noInput
    case searchingForLocation
    case locationSelected
    case polylineAdded
}