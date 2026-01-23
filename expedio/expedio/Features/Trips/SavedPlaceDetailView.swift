//
//  SavedPlaceDetailView.swift
//  Expedio
//
//  Detail view for a saved place in a trip
//

import SwiftUI
import MapKit

struct SavedPlaceDetailView: View {
    let place: SavedPlace

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
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var mapSection: some View {
        if let coord = coordinate {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker(place.name, coordinate: CLLocationCoordinate2D(
                    latitude: coord.lat, longitude: coord.lon
                ))
            }
            .frame(height: 200)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(place.displayName)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)

            if !place.category.isEmpty {
                Label(place.category, systemImage: "tag")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
            }

            if let coord = coordinate {
                Label("\(coord.lat, specifier: "%.4f"), \(coord.lon, specifier: "%.4f")",
                      systemImage: "location")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Label("Added \(place.addedAt.formatted(date: .abbreviated, time: .omitted))",
                  systemImage: "calendar")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    let place = SavedPlace(
        placeId: "123",
        name: "Eiffel Tower",
        displayName: "Eiffel Tower, Champ de Mars, Paris, France",
        category: "Tourism · Attraction",
        lat: "48.8584",
        lon: "2.2945"
    )
    return NavigationStack {
        SavedPlaceDetailView(place: place)
    }
}
