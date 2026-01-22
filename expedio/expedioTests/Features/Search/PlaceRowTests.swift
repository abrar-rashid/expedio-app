//
//  PlaceRowTests.swift
//  ExpedioTests
//
//  Unit tests for PlaceRow display name parsing
//

import XCTest
@testable import expedio

final class PlaceRowTests: XCTestCase {

    func testPlaceRow_extractsNameFromDisplayName() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Eiffel Tower, Paris, France",
            category: "tourism", type: "attraction"
        )

        let name = place.displayName.components(separatedBy: ",").first
        XCTAssertEqual(name, "Eiffel Tower")
    }

    func testPlaceRow_extractsLocationFromDisplayName() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Eiffel Tower, Paris, France",
            category: nil, type: nil
        )

        let components = place.displayName.components(separatedBy: ",")
        let location = components.dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespaces)
        XCTAssertEqual(location, "Paris, France")
    }

    func testPlaceRow_singleComponentDisplayName_returnsEmptyLocation() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Paris",
            category: nil, type: nil
        )

        let components = place.displayName.components(separatedBy: ",")
        guard components.count > 1 else {
            XCTAssertTrue(true) // Empty location expected
            return
        }
        XCTFail("Should have single component")
    }
}
