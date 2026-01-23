//
//  TripDetailView.swift
//  Expedio
//
//  Detail view for a trip showing saved places with reorder and delete
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TripDetailViewModel

    init(trip: Trip) {
        _viewModel = State(initialValue: TripDetailViewModel(trip: trip))
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if viewModel.hasPlaces {
                placesList
            } else {
                emptyView
            }
        }
        .navigationTitle(viewModel.trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.hasPlaces {
                EditButton()
            }
        }
    }

    private var placesList: some View {
        List {
            Section {
                ForEach(viewModel.sortedPlaces) { place in
                    NavigationLink(value: place) {
                        SavedPlaceRow(place: place)
                    }
                }
                .onDelete(perform: deletePlaces)
                .onMove(perform: movePlaces)
            } header: {
                tripHeader
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.background)
        .navigationDestination(for: SavedPlace.self) { place in
            SavedPlaceDetailView(place: place)
        }
    }

    private var tripHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(viewModel.trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            if let dateRange = viewModel.trip.dateRangeText {
                Text(dateRange)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .textCase(nil)
        .padding(.bottom, Theme.Spacing.sm)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Places Yet",
            systemImage: "mappin",
            description: Text("Search and add places to this trip")
        )
    }

    private func deletePlaces(at offsets: IndexSet) {
        let sortedPlaces = viewModel.sortedPlaces
        for index in offsets {
            let place = sortedPlaces[index]
            viewModel.trip.places.removeAll { $0.id == place.id }
            modelContext.delete(place)
        }
        updateOrderIndices()
        try? modelContext.save()
    }

    private func movePlaces(from source: IndexSet, to destination: Int) {
        var places = viewModel.sortedPlaces
        places.move(fromOffsets: source, toOffset: destination)

        for (index, place) in places.enumerated() {
            place.orderIndex = index
        }

        try? modelContext.save()
    }

    private func updateOrderIndices() {
        for (index, place) in viewModel.sortedPlaces.enumerated() {
            place.orderIndex = index
        }
    }
}

// MARK: - SavedPlaceRow

private struct SavedPlaceRow: View {
    let place: SavedPlace

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(place.name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(place.category)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.primary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

#Preview {
    let trip = Trip(name: "Paris Adventure", destination: "Paris, France")
    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(for: [Trip.self, SavedPlace.self], inMemory: true)
}
