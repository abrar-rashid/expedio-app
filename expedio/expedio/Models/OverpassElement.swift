//
//  OverpassElement.swift
//  Expedio
//
//  API response models for Overpass (OpenStreetMap) category queries
//

import Foundation
import CoreLocation

// MARK: - API Response

struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

// MARK: - Element

struct OverpassElement: Codable, Identifiable {
    let type: String
    let id: Int64
    let latitude: Double?
    let longitude: Double?
    let center: OverpassCenter?
    let tags: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type, id, center, tags
        case latitude = "lat"
        case longitude = "lon"
    }

    // MARK: - Computed Properties

    /// CLLocationCoordinate2D from either direct lat/lon or center
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        if let center = center {
            return CLLocationCoordinate2D(latitude: center.lat, longitude: center.lon)
        }
        return nil
    }

    /// Name from tags, with fallback
    var name: String {
        tags?["name"] ?? tags?["name:en"] ?? "Unknown Place"
    }

    /// Category derived from amenity, tourism, or shop tags
    var category: String {
        tags?["amenity"] ?? tags?["tourism"] ?? tags?["shop"] ?? tags?["leisure"] ?? ""
    }

    /// Address components combined
    var address: String? {
        let components = [
            tags?["addr:housenumber"],
            tags?["addr:street"],
            tags?["addr:city"]
        ].compactMap { $0 }

        return components.isEmpty ? nil : components.joined(separator: " ")
    }
}

// MARK: - Center (for ways/relations)

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - PlaceDisplayable Conformance

extension OverpassElement: PlaceDisplayable {
    var displayName: String {
        if let addr = address {
            return "\(name), \(addr)"
        }
        return name
    }

    /// String representation of latitude for PlaceDisplayable
    var lat: String {
        if let latValue = latitude {
            return String(latValue)
        }
        if let center = center {
            return String(center.lat)
        }
        return "0"
    }

    /// String representation of longitude for PlaceDisplayable
    var lon: String {
        if let lonValue = longitude {
            return String(lonValue)
        }
        if let center = center {
            return String(center.lon)
        }
        return "0"
    }

    var formattedCategory: String {
        category.capitalized.replacingOccurrences(of: "_", with: " ")
    }

    /// Create extratags from Overpass tags for rich data display
    var extratags: NominatimExtratags? {
        guard let tags = tags else { return nil }

        // Only create if we have at least some data
        let hasData = tags["phone"] != nil ||
                      tags["website"] != nil ||
                      tags["opening_hours"] != nil ||
                      tags["cuisine"] != nil ||
                      tags["wheelchair"] != nil

        guard hasData else { return nil }

        return NominatimExtratags(
            phone: tags["phone"] ?? tags["contact:phone"],
            website: tags["website"] ?? tags["contact:website"],
            openingHours: tags["opening_hours"],
            cuisine: tags["cuisine"],
            wheelchair: tags["wheelchair"],
            wikipedia: tags["wikipedia"],
            dietVegan: tags["diet:vegan"],
            dietVegetarian: tags["diet:vegetarian"]
        )
    }

    var savedDate: Date? { nil }
    var canAddToTrip: Bool { true }
}

// MARK: - Hashable Conformance

extension OverpassElement: Hashable {
    static func == (lhs: OverpassElement, rhs: OverpassElement) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
}
