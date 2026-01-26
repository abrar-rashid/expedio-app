//
//  DestinationTests.swift
//  expedioTests
//
//  Unit tests for Destination model
//

import XCTest
@testable import expedio

final class DestinationTests: XCTestCase {

    // MARK: - Model Properties Tests

    func testDestinationHasRequiredProperties() {
        // Given
        let destination = Destination(
            name: "Paris",
            country: "France",
            lat: 48.8566,
            lon: 2.3522
        )

        // Then
        XCTAssertEqual(destination.name, "Paris")
        XCTAssertEqual(destination.country, "France")
        XCTAssertEqual(destination.lat, 48.8566, accuracy: 0.0001)
        XCTAssertEqual(destination.lon, 2.3522, accuracy: 0.0001)
        XCTAssertNotNil(destination.id)
    }

    func testSearchQueryFormat() {
        // Given
        let destination = Destination(
            name: "Tokyo",
            country: "Japan",
            lat: 35.6762,
            lon: 139.6503
        )

        // When
        let query = destination.searchQuery

        // Then
        XCTAssertEqual(query, "Tokyo Japan travel")
    }

    func testDisplayName() {
        // Given
        let destination = Destination(
            name: "New York",
            country: "USA",
            lat: 40.7128,
            lon: -74.0060
        )

        // When
        let displayName = destination.displayName

        // Then
        XCTAssertEqual(displayName, "New York, USA")
    }

    // MARK: - Popular Destinations Tests

    func testPopularDestinationsNotEmpty() {
        // Given/When
        let destinations = Destination.popular

        // Then
        XCTAssertFalse(destinations.isEmpty)
        XCTAssertGreaterThanOrEqual(destinations.count, 12, "Should have at least 12 popular destinations")
    }

    func testPopularDestinationsContainsMajorCities() {
        // Given
        let destinations = Destination.popular
        let cityNames = destinations.map { $0.name }

        // Then - Check for major tourist destinations
        XCTAssertTrue(cityNames.contains("Paris"))
        XCTAssertTrue(cityNames.contains("Tokyo"))
        XCTAssertTrue(cityNames.contains("New York"))
        XCTAssertTrue(cityNames.contains("London"))
        XCTAssertTrue(cityNames.contains("Rome"))
    }

    func testPopularDestinationsHaveValidCoordinates() {
        // Given
        let destinations = Destination.popular

        // Then
        for destination in destinations {
            // Latitude range: -90 to 90
            XCTAssertGreaterThanOrEqual(destination.lat, -90)
            XCTAssertLessThanOrEqual(destination.lat, 90)

            // Longitude range: -180 to 180
            XCTAssertGreaterThanOrEqual(destination.lon, -180)
            XCTAssertLessThanOrEqual(destination.lon, 180)
        }
    }

    func testPopularDestinationsHaveUniqueIds() {
        // Given
        let destinations = Destination.popular

        // When
        let ids = destinations.map { $0.id }
        let uniqueIds = Set(ids)

        // Then
        XCTAssertEqual(ids.count, uniqueIds.count, "All destinations should have unique IDs")
    }

    // MARK: - Hashable Conformance Tests

    func testDestinationHashable() {
        // Given
        let destination1 = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let destination2 = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)

        // Then
        // Note: Since UUID is generated, these will have different hashes
        // But they should both be insertable into a Set
        let destinationSet: Set<Destination> = [destination1, destination2]
        XCTAssertEqual(destinationSet.count, 2, "Different instances should have different IDs")
    }

    func testDestinationEquality() {
        // Given
        let destination1 = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let destination2 = destination1

        // Then
        XCTAssertEqual(destination1.id, destination2.id)
        XCTAssertEqual(destination1.name, destination2.name)
    }
}
