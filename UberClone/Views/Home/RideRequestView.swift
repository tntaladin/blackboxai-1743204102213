import SwiftUI
import UberCore

struct RideRequestView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var tripStore: TripStore
    @State private var selectedRideType: RideType = .uberX

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(locationService.selectedLocation?.title ?? "Destination").font(.headline)
                    Spacer()
                    Button("Change") { locationService.clearSelection() }
                }
                if locationService.isRouting {
                    ProgressView("Calculating driving route…")
                } else if let error = locationService.routeError {
                    Text(error).font(.callout).foregroundStyle(.red)
                    Button("Retry route") { Task { await locationService.loadRoute() } }
                } else if let distance = locationService.distanceMeters {
                    Text("\(distance / 1000, specifier: "%.1f") km · \(locationService.arrivalText)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Picker("Ride type", selection: $selectedRideType) {
                        ForEach(RideType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }.pickerStyle(.segmented)
                    HStack {
                        Label("Up to \(selectedRideType.capacity) passengers", systemImage: "person.2.fill")
                        Spacer()
                        Text(selectedRideType.fare(distanceMeters: distance), format: .currency(code: "USD"))
                            .font(.title3.bold())
                    }.font(.caption)
                }
                Text("Demo estimate in USD. No driver is dispatched and no payment is collected.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Confirm demo ride") { confirm() }
                    .buttonStyle(.borderedProminent)
                    .disabled(locationService.distanceMeters == nil || locationService.isRouting || authService.userSession == nil)
                    .frame(maxWidth: .infinity)
            }.padding()
        }
        .frame(maxHeight: 300)
        .background(.regularMaterial)
    }

    private func confirm() {
        guard let userID = authService.userSession,
              let destination = locationService.selectedLocation,
              let distance = locationService.distanceMeters else { return }
        if tripStore.request(userID: userID,
            pickup: locationService.usingDemoLocation ? "San Francisco demo pickup" : "Current location",
            destination: destination.title, price: selectedRideType.fare(distanceMeters: distance), type: selectedRideType) {
            locationService.clearSelection()
        }
    }
}
