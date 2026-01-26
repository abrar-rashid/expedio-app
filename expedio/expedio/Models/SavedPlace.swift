//
//  SavedPlace.swift
//  Expedio
//
//  SwiftData model for saved places in a trip
//

import Foundation
import SwiftData

@Model
final class SavedPlace {
    var id: UUID
    var placeId: String
    var name: String
    var displayName: String
    var category: String
    var lat: String
    var lon: String
    var orderIndex: Int
    var addedAt: Date
    /// JSON-encoded extratags for rich place data (phone, website, hours, etc.)
    var extratagsJSON: Data?
    @Relationship(inverse: \Trip.places) var trip: Trip?

    /// Decoded extratags (computed property)
    var extratags: NominatimExtratags? {
        get {
            guard let data = extratagsJSON else { return nil }
            return try? JSONDecoder().decode(NominatimExtratags.self, from: data)
        }
        set {
            extratagsJSON = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        id: UUID = UUID(),
        placeId: String,
        name: String,
        displayName: String,
        category: String,
        lat: String,
        lon: String,
        orderIndex: Int = 0,
        addedAt: Date = Date(),
        extratagsJSON: Data? = nil,
        trip: Trip? = nil
    ) {
        self.id = id
        self.placeId = placeId
        self.name = name
        self.displayName = displayName
        self.category = category
        self.lat = lat
        self.lon = lon
        self.orderIndex = orderIndex
        self.addedAt = addedAt
        self.extratagsJSON = extratagsJSON
        self.trip = trip
    }

    convenience init(from place: NominatimPlace, orderIndex: Int = 0) {
        let extratagsData = try? JSONEncoder().encode(place.extratags)
        self.init(
            placeId: String(place.placeId),
            name: place.displayName.components(separatedBy: ",").first ?? place.displayName,
            displayName: place.displayName,
            category: place.formattedCategory,
            lat: place.lat,
            lon: place.lon,
            orderIndex: orderIndex,
            extratagsJSON: extratagsData
        )
    }

    convenience init(from element: OverpassElement, orderIndex: Int = 0) {
        let extratagsData = try? JSONEncoder().encode(element.extratags)
        self.init(
            placeId: "\(element.type)_\(element.id)",
            name: element.name,
            displayName: element.displayName,
            category: element.formattedCategory,
            lat: element.lat,
            lon: element.lon,
            orderIndex: orderIndex,
            extratagsJSON: extratagsData
        )
    }
}
