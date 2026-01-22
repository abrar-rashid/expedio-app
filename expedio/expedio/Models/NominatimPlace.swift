//
//  NominatimPlace.swift
//  Expedio
//
//  API response model for Nominatim search results
//

import Foundation

struct NominatimPlace: Codable, Identifiable, Hashable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let category: String?
    let type: String?

    var id: Int { placeId }

    var formattedCategory: String {
        [category, type]
            .compactMap { $0?.capitalized }
            .joined(separator: " · ")
    }

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat, lon
        case displayName = "display_name"
        case category = "class"
        case type
    }
}
