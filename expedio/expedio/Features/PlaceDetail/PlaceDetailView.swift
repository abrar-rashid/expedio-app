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
                if viewModel.place.extratags?.hasAnyData == true {
                    richDataSection
                }
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
                // Map renders immediately but hidden, allowing it to load in background
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
                .opacity(isMapReady ? 1 : 0)

                // Loading placeholder shows on top until map is ready
                if !isMapReady {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .fill(Theme.Colors.surface)
                        .frame(height: 200)
                        .overlay {
                            LoadingView(message: "Loading map...")
                        }
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

    @ViewBuilder
    private var richDataSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Details")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Phone
                if let phone = viewModel.place.extratags?.phone {
                    if let phoneURL = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                        Link(destination: phoneURL) {
                            Label(phone, systemImage: "phone.fill")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    } else {
                        Label(phone, systemImage: "phone.fill")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }

                // Website
                if let website = viewModel.place.extratags?.website,
                   let url = URL(string: website) {
                    Link(destination: url) {
                        Label("Website", systemImage: "globe")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                // Opening Hours
                if let hours = viewModel.place.extratags?.openingHours {
                    Label(hours, systemImage: "clock")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Cuisine
                if let cuisine = viewModel.place.extratags?.formattedCuisine {
                    Label(cuisine, systemImage: "fork.knife")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Dietary Options
                if let extratags = viewModel.place.extratags, !extratags.dietaryOptions.isEmpty {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(extratags.dietaryOptions, id: \.self) { option in
                            Text(option)
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.surface)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                                .background(Theme.Colors.primary)
                                .cornerRadius(Theme.CornerRadius.sm)
                        }
                    }
                }

                // Wheelchair Accessibility
                if let wheelchairStatus = viewModel.place.extratags?.wheelchairStatus {
                    Label(wheelchairStatus, systemImage: "figure.roll")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Wikipedia
                if let wikipedia = viewModel.place.extratags?.wikipedia {
                    let wikiURL = wikipediaURL(from: wikipedia)
                    if let url = wikiURL {
                        Link(destination: url) {
                            Label("Wikipedia", systemImage: "book.fill")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    /// Converts Wikipedia tag (e.g., "en:Eiffel Tower") to URL
    private func wikipediaURL(from tag: String) -> URL? {
        let parts = tag.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        let lang = String(parts[0])
        let article = String(parts[1]).replacingOccurrences(of: " ", with: "_")
        return URL(string: "https://\(lang).wikipedia.org/wiki/\(article)")
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
