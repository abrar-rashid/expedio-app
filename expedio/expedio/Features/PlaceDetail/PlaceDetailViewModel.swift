//
//  PlaceDetailViewModel.swift
//  Expedio
//
//  ViewModel for place detail with trip saving functionality
//

import Foundation
import SwiftData
import Observation

@Observable
final class PlaceDetailViewModel {
    let place: NominatimPlace
    private(set) var isSaving = false
    private(set) var saveError: String?

    var coordinate: (lat: Double, lon: Double)? {
        guard let lat = Double(place.lat),
              let lon = Double(place.lon) else { return nil }
        return (lat, lon)
    }

    init(place: NominatimPlace) {
        self.place = place
    }

    @MainActor
    func addToTrip(_ trip: Trip, context: ModelContext) {
        isSaving = true
        saveError = nil

        let orderIndex = trip.places.count
        let savedPlace = SavedPlace(from: place, orderIndex: orderIndex)
        savedPlace.trip = trip
        trip.places.append(savedPlace)

        do {
            try context.save()
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }
}
