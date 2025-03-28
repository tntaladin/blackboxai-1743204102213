import SwiftUI

struct RideHistoryView: View {
    @State private var rides = [Ride]()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(rides) { ride in
                        RideHistoryCell(ride: ride)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Trips")
            .onAppear {
                fetchRides()
            }
        }
    }
    
    private func fetchRides() {
        // In a real app, this would fetch from your backend
        rides = [
            Ride(
                id: "1",
                pickupLocation: "123 Main St",
                dropoffLocation: "456 Market St",
                date: Date().addingTimeInterval(-86400),
                price: 12.50,
                status: .completed
            ),
            Ride(
                id: "2",
                pickupLocation: "789 Broadway",
                dropoffLocation: "101 Mission St",
                date: Date().addingTimeInterval(-172800),
                price: 8.75,
                status: .completed
            )
        ]
    }
}

struct RideHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RideHistoryView()
            .environmentObject(AuthService())
    }
}

struct Ride: Identifiable {
    let id: String
    let pickupLocation: String
    let dropoffLocation: String
    let date: Date
    let price: Double
    let status: RideStatus
}

enum RideStatus {
    case completed
    case cancelled
    case inProgress
}

struct RideHistoryCell: View {
    let ride: Ride
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.pickupLocation)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(ride.dropoffLocation)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(ride.price.toCurrency())
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text(ride.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
        }
    }
}