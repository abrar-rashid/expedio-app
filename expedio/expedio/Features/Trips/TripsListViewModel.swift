//
//  TripsListViewModel.swift
//  Expedio
//
//  ViewModel for managing trip list state
//

import Foundation
import SwiftData
import Observation

@Observable
final class TripsListViewModel {
    var showCreateTrip = false

    func validateTripInput(name: String, destination: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Create a new trip and insert it into the context
    @MainActor
    func createTrip(
        name: String,
        destination: String,
        startDate: Date?,
        endDate: Date?,
        context: ModelContext
    ) {
        let trip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        context.insert(trip)
        try? context.save()
    }

    /// Delete a trip from the context
    @MainActor
    func deleteTrip(_ trip: Trip, context: ModelContext) {
        context.delete(trip)
        try? context.save()
    }
}
