//
//  AddToTripSheet.swift
//  Expedio
//
//  Sheet for selecting a trip to add a place to
//

import SwiftUI

struct AddToTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    let trips: [Trip]
    let onSelect: (Trip) -> Void

    var body: some View {
        NavigationStack {
            List(trips, id: \.id) { trip in
                Button {
                    onSelect(trip)
                } label: {
                    TripRow(trip: trip)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Add to Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "No Trips",
                        systemImage: "suitcase",
                        description: Text("Create a trip first to add places")
                    )
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct TripRow: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(trip.name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            if let dateRange = trip.dateRangeText {
                Text(dateRange)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
