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
    let onCreateNewTrip: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.md) {
                // Create New Trip button at the top
                Button {
                    onCreateNewTrip()
                } label: {
                    Label("Create New Trip", systemImage: "plus.circle.fill")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .stroke(Theme.Colors.primary, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.sm)

                // Existing trips
                if !trips.isEmpty {
                    List {
                        Section("Your Trips") {
                            ForEach(trips, id: \.id) { trip in
                                Button {
                                    onSelect(trip)
                                } label: {
                                    TripRow(trip: trip)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Spacer()
                }
            }
            .navigationTitle("Add to Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
