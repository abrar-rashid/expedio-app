//
//  OverpassServiceTests.swift
//  expedioTests
//
//  Unit tests for OverpassService and PlaceCategory
//

import XCTest
@testable import expedio

final class OverpassServiceTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        super.tearDown()
    }

    // MARK: - PlaceCategory Tests

    func testPlaceCategory_allCases_haveCorrectOSMTags() {
        XCTAssertEqual(PlaceCategory.restaurant.osmTagKey, "amenity")
        XCTAssertEqual(PlaceCategory.cafe.osmTagKey, "amenity")
        XCTAssertEqual(PlaceCategory.bar.osmTagKey, "amenity")
        XCTAssertEqual(PlaceCategory.museum.osmTagKey, "tourism")
        XCTAssertEqual(PlaceCategory.attraction.osmTagKey, "tourism")
        XCTAssertEqual(PlaceCategory.hotel.osmTagKey, "tourism")
        XCTAssertEqual(PlaceCategory.viewpoint.osmTagKey, "tourism")
    }

    func testPlaceCategory_displayName_isCapitalized() {
        XCTAssertEqual(PlaceCategory.restaurant.displayName, "Restaurant")
        XCTAssertEqual(PlaceCategory.cafe.displayName, "Cafe")
        XCTAssertEqual(PlaceCategory.viewpoint.displayName, "Viewpoint")
    }

    func testPlaceCategory_iconNames_areValid() {
        for category in PlaceCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) should have an icon")
        }
    }

    func testPlaceCategory_allCases_hasSeven() {
        XCTAssertEqual(PlaceCategory.allCases.count, 7)
    }

    // MARK: - OverpassService Tests

    func testFetchPlaces_validResponse_returnsElements() async throws {
        let mockData = """
        {
            "elements": [
                {"type": "node", "id": 1, "lat": 48.85, "lon": 2.35, "tags": {"name": "Café Test", "amenity": "cafe"}}
            ]
        }
        """.data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://overpass-api.de")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = OverpassService(session: session)

        let places = try await service.fetchPlaces(city: "Paris", category: .cafe)

        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places.first?.name, "Café Test")
    }

    func testFetchPlaces_serverError_throwsError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://overpass-api.de")!,
            statusCode: 500, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = OverpassService(session: session)

        do {
            _ = try await service.fetchPlaces(city: "Test", category: .restaurant)
            XCTFail("Expected error to be thrown")
        } catch let error as OverpassError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchPlaces_invalidJSON_throwsDecodingError() async {
        let mockData = "invalid json".data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://overpass-api.de")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = OverpassService(session: session)

        do {
            _ = try await service.fetchPlaces(city: "Test", category: .museum)
            XCTFail("Expected error to be thrown")
        } catch let error as OverpassError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decodingError")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchPlaces_filtersUnnamedPlaces() async throws {
        let mockData = """
        {
            "elements": [
                {"type": "node", "id": 1, "lat": 48.85, "lon": 2.35, "tags": {"name": "Named Place", "amenity": "cafe"}},
                {"type": "node", "id": 2, "lat": 48.86, "lon": 2.36, "tags": {"amenity": "cafe"}}
            ]
        }
        """.data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://overpass-api.de")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = OverpassService(session: session)

        let places = try await service.fetchPlaces(city: "Paris", category: .cafe)

        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places.first?.name, "Named Place")
    }

    func testFetchNearbyPlaces_validResponse_returnsElements() async throws {
        let mockData = """
        {
            "elements": [
                {"type": "node", "id": 1, "lat": 48.85, "lon": 2.35, "tags": {"name": "Nearby Cafe", "amenity": "cafe"}}
            ]
        }
        """.data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://overpass-api.de")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = OverpassService(session: session)

        let places = try await service.fetchNearbyPlaces(
            latitude: 48.8566,
            longitude: 2.3522,
            category: .cafe,
            radiusMeters: 1000
        )

        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places.first?.name, "Nearby Cafe")
    }
}
