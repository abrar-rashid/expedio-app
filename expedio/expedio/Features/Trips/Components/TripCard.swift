//
//  TripCard.swift
//  Expedio
//
//  Card component for displaying trip summary
//

import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(trip.name)
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            HStack {
                if let dateRange = trip.dateRangeText {
                    Label(dateRange, systemImage: "calendar")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Label("\(trip.places.count)", systemImage: "mappin.circle.fill")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}
