//
//  PlaceDetailView.swift
//  Expedio
//
//  Detail view for a selected place with trip saving functionality
//

import SwiftUI
import MapKit
import SwiftData

struct PlaceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @State private var viewModel: PlaceDetailViewModel
    @State private var showAddToTrip = false
    @State private var showSaveConfirmation = false
    @State private var isMapReady = false

    init(place: NominatimPlace) {
        _viewModel = State(initialValue: PlaceDetailViewModel(place: place))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                mapSection
                infoSection
                addToTripButton
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(placeName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddToTrip) {
            AddToTripSheet(
                trips: trips,
                onSelect: { trip in
                    addPlaceToTrip(trip)
                    showAddToTrip = false
                    showSaveConfirmation = true
                }
            )
        }
        .alert("Added to Trip", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var mapSection: some View {
        if let coord = viewModel.coordinate {
            ZStack {
                // Loading placeholder
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.surface)
                    .frame(height: 200)
                    .overlay {
                        if !isMapReady {
                            LoadingView(message: "Loading map...")
                        }
                    }

                // Map renders on top once loaded
                if isMapReady {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))) {
                        Marker(placeName, coordinate: CLLocationCoordinate2D(
                            latitude: coord.lat, longitude: coord.lon
                        ))
                    }
                    .frame(height: 200)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation {
                    isMapReady = true
                }
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(viewModel.place.displayName)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)

            if !viewModel.place.formattedCategory.isEmpty {
                Label(viewModel.place.formattedCategory, systemImage: "tag")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
            }

            if let coord = viewModel.coordinate {
                Label("\(coord.lat, specifier: "%.4f"), \(coord.lon, specifier: "%.4f")",
                      systemImage: "location")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var addToTripButton: some View {
        Button {
            showAddToTrip = true
        } label: {
            Label("Add to Trip", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
        }
        .disabled(trips.isEmpty)
    }

    private var placeName: String {
        viewModel.place.displayName.components(separatedBy: ",").first
            ?? viewModel.place.displayName
    }

    private func addPlaceToTrip(_ trip: Trip) {
        let orderIndex = trip.places.count
        let savedPlace = SavedPlace(from: viewModel.place, orderIndex: orderIndex)
        savedPlace.trip = trip
        trip.places.append(savedPlace)
        try? modelContext.save()
    }
}
