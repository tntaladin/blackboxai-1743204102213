import SwiftUI
import UberCore

struct RideHistoryView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var tripStore: TripStore

    var body: some View {
        NavigationStack {
            let rides = tripStore.history(for: authService.userSession ?? "")
            List {
                if rides.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock").font(.largeTitle)
                        Text("No trips yet").font(.headline)
                        Text("Your confirmed demo trips will appear here.")
                            .foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity).padding(.vertical, 40)
                }
                ForEach(rides) { ride in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ride.type.title).font(.headline)
                            Spacer()
                            Text(ride.price, format: .currency(code: "USD"))
                        }
                        Text("\(ride.pickupLocation) → \(ride.dropoffLocation)").font(.subheadline)
                        HStack {
                            Text(ride.date, style: .date)
                            Spacer()
                            Text(ride.status.title)
                        }.font(.caption).foregroundStyle(.secondary)
                    }.padding(.vertical, 6)
                }
            }.navigationTitle("Your trips")
        }
    }
}
