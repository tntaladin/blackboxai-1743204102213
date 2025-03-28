import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex = 0
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            RideHistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            UITabBar.appearance().backgroundColor = .systemBackground
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService())
            .environmentObject(LocationService())
    }
}