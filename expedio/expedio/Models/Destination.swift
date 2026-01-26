//
//  Destination.swift
//  Expedio
//
//  Popular travel destinations with coordinates
//

import Foundation

struct Destination: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let country: String
    let lat: Double
    let lon: Double

    /// Search query optimized for Unsplash (city + country + travel context)
    var searchQuery: String {
        "\(name) \(country) travel"
    }

    /// Display name for UI
    var displayName: String {
        "\(name), \(country)"
    }

    // MARK: - Popular Destinations

    static let popular: [Destination] = [
        Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522),
        Destination(name: "Tokyo", country: "Japan", lat: 35.6762, lon: 139.6503),
        Destination(name: "New York", country: "USA", lat: 40.7128, lon: -74.0060),
        Destination(name: "London", country: "UK", lat: 51.5074, lon: -0.1278),
        Destination(name: "Rome", country: "Italy", lat: 41.9028, lon: 12.4964),
        Destination(name: "Barcelona", country: "Spain", lat: 41.3851, lon: 2.1734),
        Destination(name: "Dubai", country: "UAE", lat: 25.2048, lon: 55.2708),
        Destination(name: "Sydney", country: "Australia", lat: -33.8688, lon: 151.2093),
        Destination(name: "Istanbul", country: "Turkey", lat: 41.0082, lon: 28.9784),
        Destination(name: "Bangkok", country: "Thailand", lat: 13.7563, lon: 100.5018),
        Destination(name: "Amsterdam", country: "Netherlands", lat: 52.3676, lon: 4.9041),
        Destination(name: "Singapore", country: "Singapore", lat: 1.3521, lon: 103.8198),
        Destination(name: "Bali", country: "Indonesia", lat: -8.4095, lon: 115.1889),
        Destination(name: "Santorini", country: "Greece", lat: 36.3932, lon: 25.4615),
        Destination(name: "Marrakech", country: "Morocco", lat: 31.6295, lon: -7.9811),
        Destination(name: "Prague", country: "Czech Republic", lat: 50.0755, lon: 14.4378),
        Destination(name: "Kyoto", country: "Japan", lat: 35.0116, lon: 135.7681),
        Destination(name: "Lisbon", country: "Portugal", lat: 38.7223, lon: -9.1393),
        Destination(name: "Vienna", country: "Austria", lat: 48.2082, lon: 16.3738),
        Destination(name: "Reykjavik", country: "Iceland", lat: 64.1466, lon: -21.9426)
    ]
}
