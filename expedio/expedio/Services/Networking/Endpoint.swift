//
//  Endpoint.swift
//  Expedio
//
//  URL construction for API endpoints
//

import Foundation

enum Endpoint {
    case search(query: String, limit: Int = 20)

    var url: URL? {
        switch self {
        case .search(let query, let limit):
            var components = URLComponents(string: "https://nominatim.openstreetmap.org/search")
            components?.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "addressdetails", value: "1")
            ]
            return components?.url
        }
    }
}
