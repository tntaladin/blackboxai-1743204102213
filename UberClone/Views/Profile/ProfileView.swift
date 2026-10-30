import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    Label(authService.currentUser?.fullname ?? "Guest", systemImage: "person.circle")
                    Text(authService.currentUser?.email ?? "").foregroundStyle(.secondary)
                }
                Section("Appearance") { Toggle("Dark mode", isOn: $darkMode) }
                Section("About this app") {
                    Text("Local ride-booking demo")
                    Text("Accounts are stored in this device's Keychain. Trips stay on this device. There are no real drivers, card charges, or server accounts.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section { Button("Sign out", role: .destructive) { authService.signout() } }
            }.navigationTitle("Profile")
        }
    }
}
