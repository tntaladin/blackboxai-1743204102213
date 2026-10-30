import SwiftUI

struct LocationSearchView: View {
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var results: [LocationItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    let onSelect: (LocationItem) -> Void

    var body: some View {
        NavigationStack {
            List {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Section("Try a destination") {
                        ForEach(locationService.demoDestinations) { item in destinationButton(item) }
                    }
                } else if isLoading {
                    ProgressView("Searching…")
                } else if let errorMessage {
                    Text(errorMessage).foregroundStyle(.secondary)
                } else if results.isEmpty {
                    Text("No places found. Try a different name or address.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(results) { item in destinationButton(item) }
                }
            }
            .navigationTitle("Where to?")
            .searchable(text: $searchText, prompt: "Place or address")
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            } }
            .task(id: searchText) { await search() }
        }
    }

    private func destinationButton(_ item: LocationItem) -> some View {
        Button {
            onSelect(item)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).foregroundStyle(.primary)
                Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func search() async {
        results = []
        errorMessage = nil
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { isLoading = false; return }
        isLoading = true
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            let found = try await locationService.searchLocations(query: query)
            try Task.checkCancellation()
            results = found
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            isLoading = false
            errorMessage = "Search is unavailable. Check your connection or try another place."
        }
    }
}
