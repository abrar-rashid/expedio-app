//
//  UnsplashPhotoTests.swift
//  ExpedioTests
//
//  Unit tests for Unsplash API models
//

import XCTest
@testable import expedio

final class UnsplashPhotoTests: XCTestCase {

    // MARK: - Decoding Tests

    func testDecoding_validJSON_decodesCorrectly() throws {
        let json = """
        {
            "total": 1,
            "total_pages": 1,
            "results": [
                {
                    "id": "abc123",
                    "urls": {
                        "raw": "https://images.unsplash.com/photo-1?raw",
                        "full": "https://images.unsplash.com/photo-1?full",
                        "regular": "https://images.unsplash.com/photo-1?regular",
                        "small": "https://images.unsplash.com/photo-1?small",
                        "thumb": "https://images.unsplash.com/photo-1?thumb"
                    },
                    "user": {
                        "id": "user1",
                        "name": "John Doe",
                        "username": "johndoe"
                    },
                    "color": "#FFFFFF",
                    "description": "A beautiful photo",
                    "alt_description": "Scenic view"
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UnsplashSearchResponse.self, from: json)

        XCTAssertEqual(response.total, 1)
        XCTAssertEqual(response.totalPages, 1)
        XCTAssertEqual(response.results.count, 1)

        let photo = response.results[0]
        XCTAssertEqual(photo.id, "abc123")
        XCTAssertEqual(photo.color, "#FFFFFF")
        XCTAssertEqual(photo.description, "A beautiful photo")
        XCTAssertEqual(photo.altDescription, "Scenic view")
    }

    func testDecoding_photo_withOptionalFieldsMissing() throws {
        let json = """
        {
            "id": "xyz789",
            "urls": {
                "raw": "https://example.com/raw",
                "full": "https://example.com/full",
                "regular": "https://example.com/regular",
                "small": "https://example.com/small",
                "thumb": "https://example.com/thumb"
            },
            "user": {
                "id": "user2",
                "name": "Jane Smith",
                "username": "janesmith"
            }
        }
        """.data(using: .utf8)!

        let photo = try JSONDecoder().decode(UnsplashPhoto.self, from: json)

        XCTAssertEqual(photo.id, "xyz789")
        XCTAssertNil(photo.color)
        XCTAssertNil(photo.description)
        XCTAssertNil(photo.altDescription)
    }

    // MARK: - URLs Tests

    func testURLs_urlForSize_returnsCorrectURL() {
        let urls = UnsplashURLs(
            raw: "https://example.com/raw",
            full: "https://example.com/full",
            regular: "https://example.com/regular",
            small: "https://example.com/small",
            thumb: "https://example.com/thumb"
        )

        XCTAssertEqual(urls.url(for: .thumbnail)?.absoluteString, "https://example.com/thumb")
        XCTAssertEqual(urls.url(for: .small)?.absoluteString, "https://example.com/small")
        XCTAssertEqual(urls.url(for: .regular)?.absoluteString, "https://example.com/regular")
        XCTAssertEqual(urls.url(for: .full)?.absoluteString, "https://example.com/full")
    }

    // MARK: - User Tests

    func testUser_profileURL_containsCorrectParams() {
        let user = UnsplashUser(id: "123", name: "Test User", username: "testuser")

        let profileURL = user.profileURL(appName: "TestApp")

        XCTAssertNotNil(profileURL)
        XCTAssertTrue(profileURL!.absoluteString.contains("@testuser"))
        XCTAssertTrue(profileURL!.absoluteString.contains("utm_source=TestApp"))
        XCTAssertTrue(profileURL!.absoluteString.contains("utm_medium=referral"))
    }

    func testUser_profileURL_defaultAppName() {
        let user = UnsplashUser(id: "123", name: "Test User", username: "testuser")

        let profileURL = user.profileURL()

        XCTAssertNotNil(profileURL)
        XCTAssertTrue(profileURL!.absoluteString.contains("utm_source=Expedio"))
    }
}
