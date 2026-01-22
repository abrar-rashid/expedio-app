//
//  NominatimService.swift
//  Expedio
//
//  API client for Nominatim geocoding service
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)

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
        }
    }
}

protocol NominatimServiceProtocol {
    func searchPlaces(query: String) async throws -> [NominatimPlace]
}

final class NominatimService: NominatimServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchPlaces(query: String) async throws -> [NominatimPlace] {
        guard let url = Endpoint.search(query: query).url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Expedio/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode([NominatimPlace].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
