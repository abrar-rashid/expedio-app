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
    let extratags: NominatimExtratags?

    var id: Int { placeId }

    /// Memberwise initializer with default nil for extratags
    init(
        placeId: Int,
        lat: String,
        lon: String,
        displayName: String,
        category: String?,
        type: String?,
        extratags: NominatimExtratags? = nil
    ) {
        self.placeId = placeId
        self.lat = lat
        self.lon = lon
        self.displayName = displayName
        self.category = category
        self.type = type
        self.extratags = extratags
    }

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
        case extratags
    }
}

// MARK: - Extratags (Rich Place Data)

struct NominatimExtratags: Codable, Hashable {
    let phone: String?
    let website: String?
    let openingHours: String?
    let cuisine: String?
    let wheelchair: String?
    let wikipedia: String?
    let dietVegan: String?
    let dietVegetarian: String?

    /// Memberwise initializer for testing and programmatic creation
    init(
        phone: String? = nil,
        website: String? = nil,
        openingHours: String? = nil,
        cuisine: String? = nil,
        wheelchair: String? = nil,
        wikipedia: String? = nil,
        dietVegan: String? = nil,
        dietVegetarian: String? = nil
    ) {
        self.phone = phone
        self.website = website
        self.openingHours = openingHours
        self.cuisine = cuisine
        self.wheelchair = wheelchair
        self.wikipedia = wikipedia
        self.dietVegan = dietVegan
        self.dietVegetarian = dietVegetarian
    }

    enum CodingKeys: String, CodingKey {
        case phone, website, cuisine, wheelchair, wikipedia
        case openingHours = "opening_hours"
        case dietVegan = "diet:vegan"
        case dietVegetarian = "diet:vegetarian"
    }

    /// Returns true if the place has any rich data to display
    var hasAnyData: Bool {
        phone != nil || website != nil || openingHours != nil ||
        cuisine != nil || wheelchair != nil || wikipedia != nil ||
        dietVegan != nil || dietVegetarian != nil
    }

    /// Formatted cuisine string (e.g., "italian;japanese" -> "Italian, Japanese")
    var formattedCuisine: String? {
        guard let cuisine = cuisine else { return nil }
        return cuisine
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespaces).capitalized }
            .joined(separator: ", ")
    }

    /// Dietary options as an array of strings
    var dietaryOptions: [String] {
        var options: [String] = []
        if dietVegan == "yes" || dietVegan == "only" {
            options.append("Vegan")
        }
        if dietVegetarian == "yes" || dietVegetarian == "only" {
            options.append("Vegetarian")
        }
        return options
    }

    /// Wheelchair accessibility status formatted for display
    var wheelchairStatus: String? {
        switch wheelchair {
        case "yes": return "Wheelchair accessible"
        case "limited": return "Limited wheelchair access"
        case "no": return "Not wheelchair accessible"
        default: return nil
        }
    }
}
