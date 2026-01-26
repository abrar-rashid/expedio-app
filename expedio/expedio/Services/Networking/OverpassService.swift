//
//  OverpassService.swift
//  Expedio
//
//  API client for Overpass (OpenStreetMap) category queries
//

import Foundation

// MARK: - Place Category

enum PlaceCategory: String, CaseIterable, Identifiable {
    case restaurant
    case cafe
    case bar
    case museum
    case attraction
    case hotel
    case viewpoint

    var id: String { rawValue }

    /// The OSM tag key for this category
    var osmTagKey: String {
        switch self {
        case .restaurant, .cafe, .bar:
            return "amenity"
        case .museum, .attraction, .hotel, .viewpoint:
            return "tourism"
        }
    }

    /// Display name for UI
    var displayName: String {
        rawValue.capitalized
    }

    /// SF Symbol for this category
    var iconName: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .bar: return "wineglass.fill"
        case .museum: return "building.columns.fill"
        case .attraction: return "star.fill"
        case .hotel: return "bed.double.fill"
        case .viewpoint: return "binoculars.fill"
        }
    }
}

// MARK: - Overpass Error

enum OverpassError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case timeout
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .timeout:
            return "Request timed out"
        case .noResults:
            return "No places found"
        }
    }
}

// MARK: - Service Protocol

protocol OverpassServiceProtocol {
    func fetchPlaces(city: String, category: PlaceCategory) async throws -> [OverpassElement]
    func fetchNearbyPlaces(latitude: Double, longitude: Double, category: PlaceCategory, radiusMeters: Int) async throws -> [OverpassElement]
}

// MARK: - Service Implementation

final class OverpassService: OverpassServiceProtocol {
    private let baseURL = "https://overpass-api.de/api/interpreter"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetch places by category within a city
    func fetchPlaces(city: String, category: PlaceCategory) async throws -> [OverpassElement] {
        let query = buildCityQuery(city: city, category: category)
        return try await executeQuery(query)
    }

    /// Fetch places by category within a radius of coordinates
    func fetchNearbyPlaces(
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        radiusMeters: Int = 1000
    ) async throws -> [OverpassElement] {
        let query = buildRadiusQuery(
            latitude: latitude,
            longitude: longitude,
            category: category,
            radius: radiusMeters
        )
        return try await executeQuery(query)
    }

    // MARK: - Private Methods

    private func buildCityQuery(city: String, category: PlaceCategory) -> String {
        // Escape special characters in city name
        let escapedCity = city.replacingOccurrences(of: "\"", with: "\\\"")

        return """
        [out:json][timeout:25];
        area["name"="\(escapedCity)"]["admin_level"~"[4-8]"]->.searchArea;
        (
          node["\(category.osmTagKey)"="\(category.rawValue)"](area.searchArea);
          way["\(category.osmTagKey)"="\(category.rawValue)"](area.searchArea);
        );
        out center body 50;
        """
    }

    private func buildRadiusQuery(
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        radius: Int
    ) -> String {
        return """
        [out:json][timeout:25];
        (
          node["\(category.osmTagKey)"="\(category.rawValue)"](around:\(radius),\(latitude),\(longitude));
          way["\(category.osmTagKey)"="\(category.rawValue)"](around:\(radius),\(latitude),\(longitude));
        );
        out center body 50;
        """
    }

    private func executeQuery(_ query: String) async throws -> [OverpassElement] {
        guard let url = URL(string: baseURL) else {
            throw OverpassError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Expedio/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = "data=\(query)".data(using: .utf8)
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OverpassError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw OverpassError.serverError(httpResponse.statusCode)
        }

        do {
            let overpassResponse = try JSONDecoder().decode(OverpassResponse.self, from: data)
            // Filter out elements without names
            return overpassResponse.elements.filter { $0.name != "Unknown Place" }
        } catch {
            throw OverpassError.decodingError(error)
        }
    }
}
