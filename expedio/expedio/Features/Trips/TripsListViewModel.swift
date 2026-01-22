//
//  TripsListViewModel.swift
//  Expedio
//
//  ViewModel for managing trip list state
//

import Foundation
import Observation

@Observable
final class TripsListViewModel {
    var showCreateTrip = false

    func validateTripInput(name: String, destination: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
