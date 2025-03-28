import SwiftUI

struct MapViewActionButton: View {
    @Binding var mapState: MapViewState
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                actionForState(mapState)
            }
        } label: {
            Image(systemName: imageNameForState(mapState))
                .font(.title2)
                .foregroundColor(.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
        }
    }
    
    func actionForState(_ state: MapViewState) {
        switch state {
        case .noInput:
            print("DEBUG: No input state")
        case .searchingForLocation:
            mapState = .noInput
        case .locationSelected, .polylineAdded:
            mapState = .noInput
        }
    }
    
    func imageNameForState(_ state: MapViewState) -> String {
        switch state {
        case .noInput:
            return "line.3.horizontal"
        case .searchingForLocation, .locationSelected, .polylineAdded:
            return "arrow.left"
        }
    }
}

struct MapViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewActionButton(mapState: .constant(.noInput))
    }
}