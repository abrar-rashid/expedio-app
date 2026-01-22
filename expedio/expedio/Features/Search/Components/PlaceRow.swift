//
//  PlaceRow.swift
//  Expedio
//
//  Row component for displaying a place in search results
//

import SwiftUI

struct PlaceRow: View {
    let place: NominatimPlace

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(placeName)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)

            if !placeLocation.isEmpty {
                Text(placeLocation)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
            }

            if !place.formattedCategory.isEmpty {
                Text(place.formattedCategory)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
    }

    private var placeName: String {
        place.displayName.components(separatedBy: ",").first ?? place.displayName
    }

    private var placeLocation: String {
        let components = place.displayName.components(separatedBy: ",")
        guard components.count > 1 else { return "" }
        return components.dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespaces)
    }
}
