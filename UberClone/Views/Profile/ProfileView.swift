import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Profile header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding(.top, 32)
                    
                    Text(authService.currentUser?.fullname ?? "Guest")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(authService.currentUser?.email ?? "no email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.vertical)
                
                // Account options
                VStack(spacing: 16) {
                    ProfileOptionRow(
                        imageName: "creditcard",
                        title: "Payment Methods"
                    )
                    
                    ProfileOptionRow(
                        imageName: "bell",
                        title: "Notifications"
                    )
                    
                    ProfileOptionRow(
                        imageName: "gear",
                        title: "Settings"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Sign out button
                Button {
                    authService.signout()
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthService())
    }
}

struct ProfileOptionRow: View {
    let imageName: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.title3)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: .constant(false))
                }
                
                Section("Preferences") {
                    NavigationLink("Language") {
                        Text("Language Settings")
                    }
                    
                    NavigationLink("Accessibility") {
                        Text("Accessibility Settings")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}