//
//  TripDetailViewModel.swift
//  Expedio
//
//  ViewModel for managing trip detail state and place operations
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
final class TripDetailViewModel {
    let trip: Trip

    init(trip: Trip) {
        self.trip = trip
    }

    var sortedPlaces: [SavedPlace] {
        trip.sortedPlaces
    }

    var hasPlaces: Bool {
        !trip.places.isEmpty
    }

    /// Move places within the trip (for drag & drop reordering)
    @MainActor
    func movePlaces(from source: IndexSet, to destination: Int, context: ModelContext) {
        var places = trip.sortedPlaces
        places.move(fromOffsets: source, toOffset: destination)

        // Update order indices
        for (index, place) in places.enumerated() {
            place.orderIndex = index
        }

        try? context.save()
    }

    /// Delete a place from the trip
    @MainActor
    func deletePlace(_ place: SavedPlace, context: ModelContext) {
        if let index = trip.places.firstIndex(where: { $0.id == place.id }) {
            trip.places.remove(at: index)
        }
        context.delete(place)
        try? context.save()
    }
}
