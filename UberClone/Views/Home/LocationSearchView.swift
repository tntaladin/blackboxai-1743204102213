import SwiftUI
import MapKit

struct LocationSearchView: View {
    @State private var searchText = ""
    @Binding var mapState: MapViewState
    @EnvironmentObject var locationService: LocationService
    @State private var results = [MKLocalSearchCompletion]()
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            // Search header
            HStack {
                Circle()
                    .fill(Color(.systemGray3))
                    .frame(width: 8, height: 8)
                
                TextField("Search for a location", text: $searchText)
                    .padding(.vertical, 8)
                    .padding(.leading, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
                    .shadow(radius: 2)
                    .onChange(of: searchText) { _ in
                        searchCompleter.queryFragment = searchText
                    }
                
                Button {
                    withAnimation(.spring()) {
                        mapState = .noInput
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 64)
            
            Divider()
            
            // Search results list
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(results, id: \.self) { result in
                        LocationSearchResultCell(
                            title: result.title,
                            subtitle: result.subtitle
                        )
                        .onTapGesture {
                            selectLocation(result)
                        }
                    }
                }
            }
        }
        .background(Color.theme.backgroundColor)
        .onAppear {
            setupSearchCompleter()
        }
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.region = locationService.region
        searchCompleter.resultTypes = .address
    }
    
    private func selectLocation(_ result: MKLocalSearchCompletion) {
        locationService.searchLocations(query: result.title)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { response in
                withAnimation(.spring()) {
                    if let item = response.first {
                        let coordinate = item.placemark.coordinate
                        locationService.selectedLocation = LocationItem(
                            title: result.title,
                            coordinate: coordinate
                        )
                        mapState = .locationSelected
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension LocationSearchView: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error in completer: \(error.localizedDescription)")
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView(mapState: .constant(.searchingForLocation))
            .environmentObject(LocationService())
    }
}

struct LocationItem: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}