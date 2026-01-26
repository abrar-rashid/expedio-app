//
//  PlaceDetailView.swift
//  Expedio
//
//  Unified detail view for any place (from search or saved trips)
//

import SwiftUI
import MapKit
import SwiftData

struct PlaceDetailView<P: PlaceDisplayable>: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]

    let place: P

    @State private var showAddToTrip = false
    @State private var showCreateTrip = false
    @State private var showSaveConfirmation = false
    @State private var isMapReady = false

    /// Initialize with a NominatimPlace (from search)
    init(place: NominatimPlace) where P == NominatimPlace {
        self.place = place
    }

    /// Initialize with a SavedPlace (from trips)
    init(place: SavedPlace) where P == SavedPlace {
        self.place = place
    }

    /// Initialize with an OverpassElement (from category browse)
    init(place: OverpassElement) where P == OverpassElement {
        self.place = place
    }

    private var coordinate: (lat: Double, lon: Double)? {
        guard let lat = Double(place.lat),
              let lon = Double(place.lon) else { return nil }
        return (lat, lon)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                mapSection
                infoSection
                if place.extratags?.hasAnyData == true {
                    richDataSection
                }
                if place.canAddToTrip {
                    addToTripButton
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(place.shortName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddToTrip) {
            AddToTripSheet(
                trips: trips,
                onSelect: { trip in
                    addPlaceToTrip(trip)
                    showAddToTrip = false
                    showSaveConfirmation = true
                },
                onCreateNewTrip: {
                    showAddToTrip = false
                    showCreateTrip = true
                }
            )
        }
        .sheet(isPresented: $showCreateTrip) {
            CreateTripSheet { name, destination, startDate, endDate in
                let trip = createTrip(name: name, destination: destination, startDate: startDate, endDate: endDate)
                addPlaceToTrip(trip)
                showCreateTrip = false
                showSaveConfirmation = true
            }
        }
        .alert("Added to Trip", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var mapSection: some View {
        if let coord = coordinate {
            ZStack {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(place.shortName, coordinate: CLLocationCoordinate2D(
                        latitude: coord.lat, longitude: coord.lon
                    ))
                }
                .frame(height: 200)
                .cornerRadius(Theme.CornerRadius.md)
                .opacity(isMapReady ? 1 : 0)

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
            Text(place.displayName)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)

            if !place.formattedCategory.isEmpty {
                Label(place.formattedCategory, systemImage: "tag")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
            }

            if let coord = coordinate {
                Label("\(coord.lat, specifier: "%.4f"), \(coord.lon, specifier: "%.4f")",
                      systemImage: "location")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            // Show "Added" date for saved places
            if let savedDate = place.savedDate {
                Label("Added \(savedDate.formatted(date: .abbreviated, time: .omitted))",
                      systemImage: "calendar")
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
                if let phone = place.extratags?.phone {
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
                if let website = place.extratags?.website,
                   let url = URL(string: website) {
                    Link(destination: url) {
                        Label("Website", systemImage: "globe")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                // Opening Hours
                if let hours = place.extratags?.openingHours {
                    Label(hours, systemImage: "clock")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Cuisine
                if let cuisine = place.extratags?.formattedCuisine {
                    Label(cuisine, systemImage: "fork.knife")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Dietary Options
                if let extratags = place.extratags, !extratags.dietaryOptions.isEmpty {
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
                if let wheelchairStatus = place.extratags?.wheelchairStatus {
                    Label(wheelchairStatus, systemImage: "figure.roll")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Wikipedia
                if let wikipedia = place.extratags?.wikipedia {
                    if let url = wikipediaURL(from: wikipedia) {
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

    private func wikipediaURL(from tag: String) -> URL? {
        let parts = tag.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        let lang = String(parts[0])
        let article = String(parts[1]).replacingOccurrences(of: " ", with: "_")
        return URL(string: "https://\(lang).wikipedia.org/wiki/\(article)")
    }

    @ViewBuilder
    private var addToTripButton: some View {
        Button {
            showAddToTrip = true
        } label: {
            Label("Add to Trip", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
        }
    }

    private func addPlaceToTrip(_ trip: Trip) {
        let orderIndex = trip.places.count
        let savedPlace: SavedPlace

        // Handle different place types
        if let nominatimPlace = place as? NominatimPlace {
            savedPlace = SavedPlace(from: nominatimPlace, orderIndex: orderIndex)
        } else if let overpassElement = place as? OverpassElement {
            savedPlace = SavedPlace(from: overpassElement, orderIndex: orderIndex)
        } else {
            return
        }

        savedPlace.trip = trip
        trip.places.append(savedPlace)
        try? modelContext.save()
    }

    private func createTrip(name: String, destination: String, startDate: Date?, endDate: Date?) -> Trip {
        let trip = Trip(name: name, destination: destination, startDate: startDate, endDate: endDate)
        modelContext.insert(trip)
        try? modelContext.save()
        return trip
    }
}
