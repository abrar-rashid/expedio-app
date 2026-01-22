//
//  PlaceDetailViewModel.swift
//  Expedio
//
//  ViewModel for place detail with trip saving functionality
//

import Foundation
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

    func setSaving(_ saving: Bool) {
        isSaving = saving
    }

    func setError(_ error: String?) {
        saveError = error
    }
}
