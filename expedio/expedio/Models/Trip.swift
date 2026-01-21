//
//  Trip.swift
//  Expedio
//
//  SwiftData model for trips
//

import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var places: [SavedPlace]

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date = Date(),
        places: [SavedPlace] = []
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.places = places
    }

    var sortedPlaces: [SavedPlace] {
        places.sorted { $0.orderIndex < $1.orderIndex }
    }

    var dateRangeText: String? {
        guard let start = startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let end = endDate {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
        return formatter.string(from: start)
    }
}
