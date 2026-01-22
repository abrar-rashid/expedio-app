//
//  TripsListView.swift
//  Expedio
//
//  Main view for displaying and managing trips
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.createdAt, order: .reverse) private var trips: [Trip]
    @State private var viewModel = TripsListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if trips.isEmpty {
                    emptyView
                } else {
                    tripsList
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showCreateTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateTrip) {
                CreateTripSheet { name, destination, start, end in
                    createTrip(name: name, destination: destination, startDate: start, endDate: end)
                    viewModel.showCreateTrip = false
                }
            }
        }
    }

    private var tripsList: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink(value: trip) {
                    TripCard(trip: trip)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: Theme.Spacing.xs,
                    leading: Theme.Spacing.md,
                    bottom: Theme.Spacing.xs,
                    trailing: Theme.Spacing.md
                ))
            }
            .onDelete(perform: deleteTrips)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.background)
        .navigationDestination(for: Trip.self) { trip in
            TripDetailView(trip: trip)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Trips Yet",
            systemImage: "suitcase",
            description: Text("Tap + to create your first trip")
        )
    }

    private func createTrip(name: String, destination: String, startDate: Date?, endDate: Date?) {
        let trip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        modelContext.insert(trip)
        try? modelContext.save()
    }

    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    TripsListView()
        .modelContainer(for: [Trip.self, SavedPlace.self], inMemory: true)
}
