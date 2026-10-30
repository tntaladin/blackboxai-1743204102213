import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var tripStore: TripStore

    var body: some View {
        Group {
            if let userID = authService.userSession {
                MainTabView().id(userID)
            } else {
                LoginView()
            }
        }
        .onChange(of: authService.userSession) { _ in locationService.clearSelection() }
        .alert("Account storage", isPresented: Binding(
            get: { authService.storageError != nil },
            set: { if !$0 { authService.storageError = nil } })) {
                Button("OK") { authService.storageError = nil }
            } message: { Text(authService.storageError ?? "") }
        .alert("Trip storage", isPresented: Binding(
            get: { tripStore.errorMessage != nil },
            set: { if !$0 { tripStore.errorMessage = nil } })) {
                Button("OK") { tripStore.errorMessage = nil }
            } message: { Text(tripStore.errorMessage ?? "") }
    }
}
