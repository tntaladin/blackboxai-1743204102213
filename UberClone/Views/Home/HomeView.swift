import SwiftUI
import UberCore

struct HomeView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var tripStore: TripStore
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            UberMapView()
                .safeAreaInset(edge: .bottom, spacing: 0) { bottomPanel }
                .navigationTitle("Book a ride")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { locationService.requestLocation() } label: {
                            Image(systemName: "location.fill")
                        }.accessibilityLabel("Use my location")
                    }
                }
                .sheet(isPresented: $showSearch) {
                    LocationSearchView { item in
                        // Selection survives the search sheet's dismissal; routing follows Home's lifecycle.
                        locationService.clearSelection()
                        locationService.selectedLocation = item
                    }
                }
                .task(id: locationService.selectedLocation?.id) {
                    if locationService.selectedLocation != nil { await locationService.loadRoute() }
                }
                .task { locationService.requestLocation() }
        }
    }

    @ViewBuilder private var bottomPanel: some View {
        if let userID = authService.userSession, let ride = tripStore.activeRide(for: userID) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Demo trip · \(ride.status.title)", systemImage: "car.fill").font(.headline)
                Text(ride.dropoffLocation)
                Text("Simulation only. No driver is dispatched and no payment is collected.")
                    .font(.caption).foregroundStyle(.secondary)
                Button(ride.status == .requested ? "Start demo trip" : "Complete demo trip") {
                    tripStore.transition(ride, userID: userID,
                        to: ride.status == .requested ? .inProgress : .completed)
                }.buttonStyle(.borderedProminent)
                Button("Cancel trip", role: .destructive) {
                    tripStore.transition(ride, userID: userID, to: .cancelled)
                }
            }.padding().frame(maxWidth: .infinity, alignment: .leading).background(.regularMaterial)
        } else if locationService.selectedLocation != nil {
            RideRequestView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Where are you going?").font(.title3.bold())
                Button { showSearch = true } label: {
                    Label("Search destination", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity).padding(8)
                }.buttonStyle(.borderedProminent)
                Text(locationService.usingDemoLocation ? "Demo pickup: San Francisco" : "Pickup: your current location")
                    .font(.caption).foregroundStyle(.secondary)
                if let message = locationService.locationMessage {
                    Text(message).font(.caption).foregroundStyle(.secondary)
                }
            }.padding().background(.regularMaterial)
        }
    }
}
