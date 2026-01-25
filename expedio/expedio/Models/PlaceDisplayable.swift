//
//  PlaceDisplayable.swift
//  Expedio
//
//  Protocol for displaying place details from any source (API or saved)
//

import Foundation

/// Protocol that allows displaying place details from different data sources
protocol PlaceDisplayable {
    var displayName: String { get }
    var lat: String { get }
    var lon: String { get }
    var formattedCategory: String { get }
    var extratags: NominatimExtratags? { get }

    /// Short name for navigation title (first component of display name)
    var shortName: String { get }

    /// Whether this is a saved place (shows "Added" date)
    var savedDate: Date? { get }

    /// Whether to show "Add to Trip" button
    var canAddToTrip: Bool { get }
}

// MARK: - Default Implementations

extension PlaceDisplayable {
    var shortName: String {
        displayName.components(separatedBy: ",").first ?? displayName
    }

    var coordinate: (lat: Double, lon: Double)? {
        guard let latValue = Double(lat),
              let lonValue = Double(lon) else { return nil }
        return (latValue, lonValue)
    }
}

// MARK: - NominatimPlace Conformance

extension NominatimPlace: PlaceDisplayable {
    var savedDate: Date? { nil }
    var canAddToTrip: Bool { true }
}

// MARK: - SavedPlace Conformance

extension SavedPlace: PlaceDisplayable {
    var formattedCategory: String { category }
    var savedDate: Date? { addedAt }
    var canAddToTrip: Bool { false }
}
