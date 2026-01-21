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
    @Relationship(inverse: \Trip.places) var trip: Trip?

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
        self.trip = trip
    }
}
