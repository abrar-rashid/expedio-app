//
//  PlaceDetailView.swift
//  Expedio
//
//  Detail view for a selected place (full implementation in Phase 4)
//

import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: NominatimPlace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                mapSection
                infoSection
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(placeName)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var mapSection: some View {
        if let coord = coordinate {
            ZStack {
                // Loading placeholder
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.surface)
                    .frame(height: 200)
                    .overlay {
                        LoadingView(message: "Loading map...")
                    }

                // Map renders on top once loaded
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
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var placeName: String {
        place.displayName.components(separatedBy: ",").first ?? place.displayName
    }

    private var coordinate: (lat: Double, lon: Double)? {
        guard let lat = Double(place.lat),
              let lon = Double(place.lon) else { return nil }
        return (lat, lon)
    }
}
