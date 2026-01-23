//
//  UnsplashService.swift
//  Expedio
//
//  API client for Unsplash image service
//
//  IMPORTANT: Replace the placeholder API key with your own.
//  Get a free API key at: https://unsplash.com/developers
//

import Foundation

// MARK: - Protocol

protocol UnsplashServiceProtocol {
    func searchPhotos(query: String, perPage: Int) async throws -> [UnsplashPhoto]
}

// MARK: - Service

final class UnsplashService: UnsplashServiceProtocol {
    private let session: URLSession
    private let accessKey: String
    private let baseURL = "https://api.unsplash.com"

    /// Initialize with API access key
    /// - Parameters:
    ///   - accessKey: Your Unsplash API access key
    ///   - session: URLSession for requests (default: .shared)
    init(accessKey: String = UnsplashConfig.accessKey, session: URLSession = .shared) {
        self.accessKey = accessKey
        self.session = session
    }

    /// Search for photos matching the query
    /// - Parameters:
    ///   - query: Search term (e.g., "Paris France travel")
    ///   - perPage: Number of results (default: 1)
    /// - Returns: Array of matching photos
    func searchPhotos(query: String, perPage: Int = 1) async throws -> [UnsplashPhoto] {
        guard !accessKey.isEmpty && accessKey != "YOUR_UNSPLASH_ACCESS_KEY" else {
            throw UnsplashError.missingAPIKey
        }

        var components = URLComponents(string: "\(baseURL)/search/photos")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "orientation", value: "landscape")
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let searchResponse = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
            return searchResponse.results
        case 401:
            throw UnsplashError.invalidAPIKey
        case 403:
            throw UnsplashError.rateLimitExceeded
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Errors

enum UnsplashError: LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Unsplash API key not configured. Please add your API key."
        case .invalidAPIKey:
            return "Invalid Unsplash API key. Please check your configuration."
        case .rateLimitExceeded:
            return "Unsplash API rate limit exceeded. Please try again later."
        }
    }
}

// MARK: - Configuration

/// Configuration for Unsplash API
enum UnsplashConfig {
    /// Your Unsplash API access key (loaded from Secrets.swift)
    static let accessKey = Secrets.unsplashAccessKey

    /// Attribution link to Unsplash (required by API terms)
    static func unsplashURL(appName: String = "Expedio") -> URL? {
        URL(string: "https://unsplash.com/?utm_source=\(appName)&utm_medium=referral")
    }
}
