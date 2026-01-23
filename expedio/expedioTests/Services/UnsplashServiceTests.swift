//
//  UnsplashServiceTests.swift
//  ExpedioTests
//
//  Unit tests for UnsplashService
//

import XCTest
@testable import expedio

final class UnsplashServiceTests: XCTestCase {

    // MARK: - Mock Service

    class MockUnsplashService: UnsplashServiceProtocol {
        var searchResult: Result<[UnsplashPhoto], Error> = .success([])
        var searchCallCount = 0
        var lastQuery: String?
        var lastPerPage: Int?

        func searchPhotos(query: String, perPage: Int) async throws -> [UnsplashPhoto] {
            searchCallCount += 1
            lastQuery = query
            lastPerPage = perPage

            switch searchResult {
            case .success(let photos):
                return photos
            case .failure(let error):
                throw error
            }
        }
    }

    // MARK: - Tests

    func testSearchPhotos_success_returnsPhotos() async throws {
        let mockService = MockUnsplashService()
        let expectedPhoto = createMockPhoto(id: "test123")
        mockService.searchResult = .success([expectedPhoto])

        let photos = try await mockService.searchPhotos(query: "Paris", perPage: 1)

        XCTAssertEqual(photos.count, 1)
        XCTAssertEqual(photos[0].id, "test123")
        XCTAssertEqual(mockService.lastQuery, "Paris")
        XCTAssertEqual(mockService.lastPerPage, 1)
    }

    func testSearchPhotos_failure_throwsError() async {
        let mockService = MockUnsplashService()
        mockService.searchResult = .failure(UnsplashError.rateLimitExceeded)

        do {
            _ = try await mockService.searchPhotos(query: "Test", perPage: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is UnsplashError)
        }
    }

    func testSearchPhotos_multipleResults() async throws {
        let mockService = MockUnsplashService()
        let photos = [
            createMockPhoto(id: "photo1"),
            createMockPhoto(id: "photo2"),
            createMockPhoto(id: "photo3")
        ]
        mockService.searchResult = .success(photos)

        let result = try await mockService.searchPhotos(query: "Tokyo", perPage: 3)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(mockService.searchCallCount, 1)
    }

    // MARK: - Error Tests

    func testUnsplashError_missingAPIKey_hasDescription() {
        let error = UnsplashError.missingAPIKey

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("API key"))
    }

    func testUnsplashError_invalidAPIKey_hasDescription() {
        let error = UnsplashError.invalidAPIKey

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Invalid"))
    }

    func testUnsplashError_rateLimitExceeded_hasDescription() {
        let error = UnsplashError.rateLimitExceeded

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("rate limit"))
    }

    // MARK: - Config Tests

    func testUnsplashConfig_unsplashURL_containsParams() {
        let url = UnsplashConfig.unsplashURL(appName: "TestApp")

        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("unsplash.com"))
        XCTAssertTrue(url!.absoluteString.contains("utm_source=TestApp"))
    }

    // MARK: - Helpers

    private func createMockPhoto(id: String) -> UnsplashPhoto {
        UnsplashPhoto(
            id: id,
            urls: UnsplashURLs(
                raw: "https://example.com/raw",
                full: "https://example.com/full",
                regular: "https://example.com/regular",
                small: "https://example.com/small",
                thumb: "https://example.com/thumb"
            ),
            user: UnsplashUser(id: "user1", name: "Test User", username: "testuser"),
            color: "#FFFFFF",
            description: "Test photo",
            altDescription: "A test photo"
        )
    }
}
