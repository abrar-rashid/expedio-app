//
//  TripDetailViewModel.swift
//  Expedio
//
//  ViewModel for managing trip detail state and place operations
//

import Foundation
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
}
