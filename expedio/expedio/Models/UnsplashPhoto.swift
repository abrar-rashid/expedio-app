//
//  UnsplashPhoto.swift
//  Expedio
//
//  API response models for Unsplash image service
//

import Foundation

// MARK: - Search Response

struct UnsplashSearchResponse: Codable {
    let results: [UnsplashPhoto]
    let total: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case results, total
        case totalPages = "total_pages"
    }
}

// MARK: - Photo

struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let urls: UnsplashURLs
    let user: UnsplashUser
    let color: String?
    let description: String?
    let altDescription: String?

    enum CodingKeys: String, CodingKey {
        case id, urls, user, color, description
        case altDescription = "alt_description"
    }
}

// MARK: - URLs

struct UnsplashURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String

    /// Returns the most appropriate URL for the given size
    func url(for size: ImageSize) -> URL? {
        let urlString: String
        switch size {
        case .thumbnail: urlString = thumb
        case .small: urlString = small
        case .regular: urlString = regular
        case .full: urlString = full
        }
        return URL(string: urlString)
    }
}

enum ImageSize {
    case thumbnail  // 200px
    case small      // 400px
    case regular    // 1080px
    case full       // Original
}

// MARK: - User (for attribution)

struct UnsplashUser: Codable {
    let id: String
    let name: String
    let username: String

    /// Attribution link to photographer profile (required by Unsplash)
    func profileURL(appName: String = "Expedio") -> URL? {
        URL(string: "https://unsplash.com/@\(username)?utm_source=\(appName)&utm_medium=referral")
    }
}
