//
//  NominatimPlaceTests.swift
//  ExpedioTests
//
//  Unit tests for NominatimPlace API model
//

import XCTest
@testable import expedio

final class NominatimPlaceTests: XCTestCase {

    func testDecoding_validJSON_decodesCorrectly() throws {
        let json = """
        {
            "place_id": 123,
            "lat": "48.8566",
            "lon": "2.3522",
            "display_name": "Paris, France",
            "class": "place",
            "type": "city"
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertEqual(place.placeId, 123)
        XCTAssertEqual(place.lat, "48.8566")
        XCTAssertEqual(place.lon, "2.3522")
        XCTAssertEqual(place.displayName, "Paris, France")
        XCTAssertEqual(place.category, "place")
        XCTAssertEqual(place.type, "city")
    }

    func testDecoding_missingOptionalFields_decodesSuccessfully() throws {
        let json = """
        {
            "place_id": 456,
            "lat": "51.5074",
            "lon": "-0.1278",
            "display_name": "London, UK"
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertEqual(place.placeId, 456)
        XCTAssertNil(place.category)
        XCTAssertNil(place.type)
    }

    func testFormattedCategory_bothValues_joinedWithDot() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: "tourism", type: "hotel"
        )
        XCTAssertEqual(place.formattedCategory, "Tourism · Hotel")
    }

    func testFormattedCategory_onlyCategory_returnsCapitalized() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: "amenity", type: nil
        )
        XCTAssertEqual(place.formattedCategory, "Amenity")
    }

    func testFormattedCategory_noValues_returnsEmpty() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        XCTAssertEqual(place.formattedCategory, "")
    }

    func testId_returnsPlaceId() {
        let place = NominatimPlace(
            placeId: 999, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        XCTAssertEqual(place.id, 999)
    }
}
