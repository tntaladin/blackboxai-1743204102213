import SwiftUI

@main
struct UberCloneApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var locationService = LocationService()
    @StateObject private var tripStore = TripStore()
    @AppStorage("darkMode") private var darkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(locationService)
                .environmentObject(tripStore)
                .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}
