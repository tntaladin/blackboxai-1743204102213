import SwiftUI
import MapKit

struct HomeView: View {
    @State private var showLocationSearchView = false
    @State private var showRideRequestView = false
    @State private var mapState = MapViewState.noInput
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                UberMapView(mapState: $mapState)
                    .ignoresSafeArea()
                
                if mapState == .searchingForLocation {
                    LocationSearchView(mapState: $mapState)
                } else if mapState == .noInput {
                    LocationSearchActivationView()
                        .padding(.top, 72)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                mapState = .searchingForLocation
                            }
                        }
                }
                
                MapViewActionButton(mapState: $mapState)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            
            if showRideRequestView {
                RideRequestView()
                    .transition(.move(edge: .bottom))
            }
        }
        .onReceive(locationService.$selectedLocation) { location in
            if location != nil {
                self.showRideRequestView = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LocationService())
    }
}